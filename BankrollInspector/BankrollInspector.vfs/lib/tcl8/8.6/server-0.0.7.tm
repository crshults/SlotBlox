package require TclOO

oo::class create server {
    variable _clients _connected_callback _received_callback _server_channel

    constructor {port received_callback {connected_callback {}}} {
        set _clients [list]
        set _received_callback $received_callback
        set _connected_callback $connected_callback
        set _server_channel [socket -server [list [self] accept_connection] $port]
    }

    destructor {
        foreach client_channel $_clients {
            close $client_channel
        }
        chan close $_server_channel
    }

    method accept_connection {client_channel address port} {
        lappend _clients $client_channel
        chan configure $client_channel -blocking no -buffering none -encoding iso8859-1 -translation binary
        chan event $client_channel readable [list [self] read_data $client_channel]
        catch {$_connected_callback $client_channel}
    }

    method read_data {client_channel} {
        set message [chan read $client_channel]
        if {[chan eof $client_channel]} {
            chan close $client_channel
            set _clients [lsearch -inline -all -not -exact $_clients $client_channel]
        } else {
            $_received_callback $client_channel $message
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
