# ******************************************************************************
# MIT License
# 
# Copyright © 2021 Chris Shults
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# ******************************************************************************
# * The service_locator library is a Tcl module that allows you to automatically
# * discover the connection details of a service that you wish to use.
# *
# * Once a find service request is initiated, the module will continue to look
# * for the desired service until it is found. It does this by sending UDP
# * broadcasts in the hope that a corresponding service_location_provider will
# * reply with connection details. The requests will be resent at an interval of
# * 1 second until a response is received.
# *

package provide service_locator 0.1.0

package require udp
package require TclOO

oo::class create service_locator {

	# The Service Locator will use a single UDP socket to sequentially send
	# broadcasts on all interfaces in order to try to locate the connection
	# details of the service that is being sought
	variable _udp_socket

	# The name of the service we are currently seeking is stored in order to
	# determine if received service connection detail responses match the
	# service we are currently attempting to locate
	variable _service_name

	# When we receive the connection details of the service that is being
	# located, the details will be relayed back to the original requester via a
	# callback procedure
	variable _service_located_callback

	# In order to keep attempting to obtain the connection details of a sought
	# service, a retry procedure will be scheduled every 1 second until a
	# Service Location Provider responds with the connection details for the
	# service we are currently attempting to locate.
	variable _scheduled_retry

	# Flag indicating whether or not we are currently attempting to obtain the
	# connection details of a service
	variable _finding

	constructor {} {

		# Port 15353 is a riff off of the mDNS port number of 5353
		set _udp_socket               [udp_open 15353 reuse]
		set _service_name             unknown
		set _service_located_callback {}
		set _finding                  no

		# Configure the UDP socket for broadcasting, so that messages will be
		# immediately sent, and so reads will not hang when no data is available
		chan configure $_udp_socket \
			-blocking  0            \
			-buffering none         \
			-broadcast 1            \

		# Wire up the event handler to read received broadcasts
		chan event $_udp_socket readable [
			list [self] handle_received_message $_udp_socket
		]
	}

	destructor {

		after cancel $_scheduled_retry
		catch {chan close $_udp_socket}
	}

	method handle_received_message {udp_socket} {

		# need to read the sender details before we read the data to avoid
		# destroying the packet
		set ip_address [lindex [chan configure $udp_socket -peer] 0]
		set message    [chan read $udp_socket]
		set port       [lindex $message end]

		# Only do further handling on the received broadcast if we are currently
		# seeking a service location and the received message contains a service
		# location description for the service we are looking for.
		if {$_finding && [
			string compare "service location $_service_name" [
				lrange $message 0 2
			]] eq 0} {

			# Cancel the pending retry and go back to the not finding state.
			after cancel $_scheduled_retry
			set _finding no

			# Relay the IP Address and the port number of the service back to
			# the client so they can make the appropriate TCP connection to the
			# service.
			catch {{*}$_service_located_callback [list $ip_address $port]}
		}
	}

	method find {service_name callback} {

		# Store the name of the service being sought along with the callback
		# function to invoke when the service is found
		set _service_name $service_name
		set _service_located_callback $callback

		# Schedule a retry to fire 1 second from now and flag that we are now in
		# a finding state
		set _scheduled_retry [
			after 1000 [list [self] find $service_name $callback]
		]

		set _finding yes

		# get the current set of broadcast addresses for the system
		package forget  system_info
		package require system_info

		# Send the request broadcast
		# Doing this last to avoid tkcon race conditions
		foreach broadcast_address $system_info::broadcast_addresses {

			chan configure $_udp_socket -remote [list $broadcast_address 15353]
			chan puts -nonewline $_udp_socket "service find $service_name"
		}

		if {[llength $system_info::broadcast_addresses] eq 0} {

			# No broadcast addresses were found so use the localhost broadcast
			# address.
			chan configure $_udp_socket -remote [list 127.255.255.255 15353]
			chan puts -nonewline $_udp_socket "service find $service_name"
		}

		return
	}

}
