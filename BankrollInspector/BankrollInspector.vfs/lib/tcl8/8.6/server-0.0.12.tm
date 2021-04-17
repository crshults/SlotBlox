package provide server 0.0.12

package require TclOO
package require system_information
package require service_location_provider

oo::class create server {
    variable _clients _received_callback _server_channel
    variable _service_location_provider

    constructor {received_callback {scope global} {port 0}} {
        set _clients [list]
        set _received_callback $received_callback
        if {$scope eq "local"} {
            set _server_channel [socket -server [list [self] accept_connection] -myaddr $::system_information::ip_address $port]
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
        chan configure $client_channel -blocking no -buffering none -encoding iso8859-1 -translation binary
        chan event $client_channel readable [list [self] read_data $client_channel]
    }

    method read_data {client_channel} {
        set message [chan read $client_channel]
        if {[chan eof $client_channel]} {
            chan close $client_channel
            set _clients [lsearch -inline -all -not -exact $_clients $client_channel]
        } else {
            catch {$_received_callback $client_channel $message}
        }
    }

    method broadcast {message {newline no}} {
        foreach client $_clients {
            my send $client $message $newline
        }
    }

    method send {client message {newline no}} {
        if {$newline == no} {
            catch {chan puts -nonewline $client $message}
        } else {
            catch {chan puts $client $message}
        }
    }
}
