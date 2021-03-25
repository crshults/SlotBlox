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
# * The service_location_provider is a Tcl module that allows you to make the
# * connection details of a service discoverable by other clients on the
# * network.
# *
# * A service_location_provider object is created with a service name, a scope
# * of either local or global, and a service port which corresponds to the TCP
# * port number at which the service endpoint resides.
# *
# * If the scope is set to local, the service port number will only be disclosed
# * to clients sending the discovery request from the same IP Address.
# *

package provide service_location_provider 0.1.0

package require udp
package require TclOO
source system_info-0.1.0.tm

oo::class create service_location_provider {

	variable _udp_socket _service_name _scope _service_port

	constructor {service_name scope service_port} {

		# The scope must be defined as either global or local
		if {$scope ni {local global}} {

			error "scope must be {local} or {global}"
		}

		# Port 15353 is a riff off of the mDNS port number of 5353
		set _udp_socket   [udp_open 15353 reuse]
		set _service_name $service_name
		set _scope        $scope
		set _service_port $service_port

		# Configure the UDP socket for broadcasting, so that messages will be
		# immediately sent, and so reads will not hang when no data is available
		chan configure $_udp_socket \
			-blocking  0            \
			-buffering none

		# Wire up the event handler to read received broadcasts
		chan event $_udp_socket readable [list [self] handle_received_message]
	}

	destructor {

		catch {chan close $_udp_socket}
	}

	method handle_received_message {} {

		set sender_ip_address [lindex [chan configure $_udp_socket -peer] 0]
		set message [chan read $_udp_socket]
		set sender_broadcast_address [
			join [
				lreplace [
					split $sender_ip_address .
				] end end 255
			] .
		]

		# Service connection details will not be disclosed outside this IP
		# Address for services that are declared as local.
		if {$_scope eq "local" &&
		    $sender_ip_address ni $system_info::ip_addresses} {

			return
		}

		if {$message eq "service find $_service_name"} {

			chan configure $_udp_socket -remote [
				list $sender_broadcast_address 15353
			]

			# Broadcast the service connection details back to the requester if
			# this is the service being sought.
			chan puts -nonewline $_udp_socket \
				"service location $_service_name $_service_port"

		}
	}

}
