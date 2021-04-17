package provide server 0.0.16

package require TclOO
package require system_information
package require service_location_provider

oo::class create server {
    variable _clients _received_callback _server_channel _disconnected_callback
    variable _service_location_provider

    constructor {received_callback {disconnected_callback {}} {scope local} {port 0}} {
        set _clients [list]
        set _received_callback $received_callback
        set _disconnected_callback $disconnected_callback
        if {$scope eq "local"} {
            set _server_channel [socket -server [list [self] accept_connection] -myaddr 127.0.0.1 $port]
        } else {
            set _server_channel [socket -server [list [self] accept_connection] $port]
        }
        set _service_location_provider [service_location_provider new [string trimleft [self object] :] $scope [lindex [chan configure $_server_channel -sockname] 2]]
    }

    destructor {
        foreach client_channel $_clients {
            close $client_channel
        }
        chan close $_server_channel
        $_service_location_provider destroy
    }

    method accept_connection {client_channel address port} {
        lappend _clients $client_channel
        chan configure $client_channel -blocking no -buffering line -encoding iso8859-1 -translation binary
        chan event $client_channel readable [list [self] read_data $client_channel]
    }

    method read_data {client_channel} {
        set message [chan gets $client_channel]
		if {[chan eof $client_channel]} {
			chan close $client_channel
			set _clients [lsearch -inline -all -not -exact $_clients $client_channel]
            catch {$_disconnected_callback $client_channel}
		} else {
			if {[string length $message]} {
				catch {$_received_callback $message $client_channel}
			}
		}
    }

    method broadcast {message} {
        foreach client $_clients {
            my send $client $message
        }
    }

    method send {client message} {
        catch {chan puts $client $message}
    }
}
