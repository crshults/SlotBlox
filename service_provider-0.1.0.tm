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
# * The service_provider library is a Tcl module that allows an application to
# * provide services to local and remote users.
# *

package provide service_provider 0.1.0

package require TclOO
package require service_location_provider

oo::class create service_provider {

	# The switchboard is the server socket that clients will connect to in order
	# to establish a connection with and use the provided service.
	variable _switchboard

	# Each client connection that gets created when a user contacts the
	# switchboard will be stored in a list.
	variable _user_connections

	# When a message is received from the user, the message will be sent back to
	# the application via the received callback
	variable _received_callback

	# When a client disconnects from the service, a notification will be sent to
	# the application in case it had established any dependencies on certain
	# client connections being established and available.
	variable _disconnected_callback

	# The service location provider allows local and remote clients to use an
	# out-of-band method to determine the connection details for this
	# application's switchboard.
	variable _service_location_provider

	constructor {
		received_callback
		{disconnected_callback {}}
		{scope local}
		{port 0}
	} {

		set _user_connections [list]
		set _received_callback $received_callback
		set _disconnected_callback $disconnected_callback

		# The switchboard is a server socket that listens for incoming
		# connections on the specified port. If no port is specified, a random
		# port number will be assigned.
		set _switchboard [
			socket -server [list [self] accept_connection] $port
		]

		# A service location provider is created for this application so that
		# users can discover the connection details for this service's
		# switchboard.
		set _service_location_provider [
			service_location_provider new [string trimleft [self object] :] \
				$scope [lindex [chan configure $_switchboard -sockname] 2]
		]
	}

	destructor {

		# On destruction, close down all the user connections
		foreach user_connection $_user_connections {

			close $user_connection
		}

		# close down the switchboard
		chan close $_switchboard

		# Also destroy the service location provider
		$_service_location_provider destroy
	}

	method accept_connection {user_connection address port} {

		# When a user connection first comes in on the switchboard, add that
		# user connection to the list.
		lappend _user_connections $user_connection

		# configure the new user connection for non-blocking, line buffering,
		# and set the encoding and translation so data will send and receive
		# properly.
		chan configure $user_connection \
			-blocking    no             \
			-buffering   line           \
			-encoding    iso8859-1      \
			-translation binary

		# Subscribe the read_data method to this user connection's readable
		# event so that when messages arrive from the user, they can be
		# forwarded to the application.
		chan event $user_connection readable [
			list [self] read_data $user_connection
		]
	}

	method read_data {user_connection} {

		# A message has arrived from the user, so retrieve it.
		set message [chan gets $user_connection]

		if {[chan eof $user_connection]} {

			# When the end of the data stream has been reached, this means the
			# user has disconnected, so close the user connection at this time.
			chan close $user_connection

			# Remove this user connection from the list of user connections.
			set _user_connections [
				lsearch -inline -all -not -exact $_user_connections \
					$user_connection
			]

			# Notify the application that this user is now disconnected. Not all
			# applications care about disconnections so the callback may not be
			# defined.
			catch {$_disconnected_callback $user_connection}

		} else {

			if {[string length $message]} {

				# When a non-0 length message arrives, forward it to the
				# application along with which user it is from.
				# TODO: Remember why the catch was here
				catch {$_received_callback $message $user_connection}
			}
		}
	}

	method broadcast {message} {

		# Broadcast messages are sent to all connected users.
		foreach user_connection $_user_connections {

			my send $user_connection $message
		}
	}

	method send {user_connection message} {

		# Sends are targeted at a specific user.
		catch {chan puts $user_connection $message}
	}
}
