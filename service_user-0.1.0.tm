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
# * The service_user library is a Tcl module that allows an application to use
# * the services being offered by local and remote providers.
# *

package provide service_user 0.1.0

package require TclOO
package require service_locator

oo::class create service_user {

	variable _client_socket
	variable _connected
	variable _address
	variable _port
	variable _callback
	variable _awaiting_connection_result
	variable _connected_callback
	variable _disconnected_callback
	variable _service_locator
	variable _service_name

	constructor {
		service_name
		callback
		{connected_callback {}}
		{disconnected_callback {}}
	} {

		set _service_name $service_name
		set _address unknown
		set _port unknown
		set _connected no
		set _callback $callback
		set _connected_callback $connected_callback
		set _disconnected_callback $disconnected_callback
		set _service_locator [service_locator new]

		# Upon creation, start trying to locate the service we wish to use at
		# the first available opportunity.
		after idle [list [self] find_service]

		# Signal to the application that we are currently in a disconnected
		# state
		catch {$_disconnected_callback}
	}

	destructor {

		# On destruction, close down the communications channel and destroy the
		# service locator
		catch {chan close $_client_socket}
		$_service_locator destroy
	}

	method find_service {} {

		# Make sure when we are in the finding state that the communications
		# channel is in a closed state.
		catch {chan close $_client_socket}

		# If we started finding the service again after previously being
		# connected, notify the application that we are in a disconnected state
		# now.
		if {$_connected} {

			catch {$_disconnected_callback}
		}

		# Flag that we are not connected and start the service locator's finding
		# process.
		set _connected no
		$_service_locator find $_service_name [list [self] service_found]
	}

	method service_found {address} {

		# The service has been found so take the service connection details and
		# store them, then connect to the service.
		set _address [lindex $address 0]
		set _port [lindex $address 1]
		my connect
	}

	method connect {} {

		# Ensure the communications channel is in a closed state before we
		# attempt to make a connection.
		catch {chan close $_client_socket}

		# Flag that we are not yet connected and start the asynchronous
		# connection process.
		set _connected no
		set _client_socket [socket -async $_address $_port]
		set _awaiting_connection_result yes

		# Configure the communications channel to exchange data properly with
		# the service provider.
		chan configure $_client_socket -blocking no -buffering line \
			-encoding iso8859-1 -translation binary

		# Subscribe the channel communications events.
		chan event $_client_socket readable [list [self] read_data]
		chan event $_client_socket writable [list [self] connection_result]
	}

	method connection_result {} {

		# When the communications channel makes a connection or times out trying
		# to make a connection, the writable event will fire.
		set _awaiting_connection_result no

		if {[chan configure $_client_socket -error] == ""} {

			# If there is no error, then we have successfully made a connection.
			set _connected yes
			catch {$_connected_callback}

		} else {

			# Otherwise unsubscribe from the readable event and start the
			# process of locating the service again.
			chan event $_client_socket readable {}
			after idle [list [self] find_service]
		}

		# Unsubscribe from the wriatable event
		chan event $_client_socket writable {}
	}

	method read_data {} {

		if {[chan configure $_client_socket -error] != "" &&
		    !$_awaiting_connection_result} {

			# When there is an error on the channel and we are not waiting for
			# the asynchronous connection to be established, go back to the
			# process of locating the service.
			my find_service
			return
		}

		if {[catch {set message [chan gets $_client_socket]}]} {

			# If an unexpected error occurs while trying to read a message from
			# the communications channel, go back to the process of locating the
			# service.
			my find_service
			return
		}

		if {[string length $message]} {

			# If there is a message, forward it to the application.
			{*}$_callback $message
		}

		if {[chan eof $_client_socket]} {

			# If the communications channel has reached end-of-file, go back to
			# the process of locating the service.
			my find_service
			return
		}
	}

	method send {message} {

		if {$_connected} {

			# Send a message to the service provider
			if {[catch {chan puts $_client_socket $message}]} {

				# If an unexpected error occurs while trying to send a message
				# through the communications channel, go back to the process of
				# locating the service.
				my find_service
				error "client not connected"
			}

		} else {

			error "client not connected"
		}
	}
}
