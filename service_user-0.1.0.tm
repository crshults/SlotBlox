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
		after idle [list [self] find_service]
		catch {$_disconnected_callback}
	}

	destructor {

		catch {chan close $_client_socket}
		$_service_locator destroy
	}

	method find_service {} {

		catch {chan close $_client_socket}

		if {$_connected} {

			catch {$_disconnected_callback}
		}

		set _connected no
		$_service_locator find $_service_name [list [self] service_found]
	}

	method service_found {address} {

		set _address [lindex $address 0]
		set _port [lindex $address 1]
		my connect
	}

	method connect {} {

		catch {chan close $_client_socket}
		set _connected no
		set _client_socket [socket -async $_address $_port]
		set _awaiting_connection_result yes
		chan configure $_client_socket -blocking no -buffering line \
			-encoding iso8859-1 -translation binary
		chan event $_client_socket readable [list [self] read_data]
		chan event $_client_socket writable [list [self] connection_result]
	}

	method connection_result {} {

		set _awaiting_connection_result no

		if {[chan configure $_client_socket -error] == ""} {

			set _connected yes
			catch {$_connected_callback}

		} else {

			chan event $_client_socket readable {}
			after idle [list [self] find_service]
		}

		chan event $_client_socket writable {}
	}

	method read_data {} {

		if {[chan configure $_client_socket -error] != "" && !$_awaiting_connection_result} {

			my find_service
			return
		}

		if {[catch {set message [chan gets $_client_socket]}]} {

			my find_service
			return
		}

		if {[string length $message]} {

			{*}$_callback $message
		}

		if {[chan eof $_client_socket]} {

			my find_service
			return
		}
	}

	method send {message} {

		if {$_connected} {

			if {[catch {chan puts $_client_socket $message}]} {

				my find_service
				error "client not connected"
			}

		} else {

			error "client not connected"
		}
	}
}
