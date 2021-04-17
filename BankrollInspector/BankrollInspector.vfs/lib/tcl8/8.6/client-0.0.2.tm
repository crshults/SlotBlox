package provide client 0.0.2
package require TclOO

oo::class create client {
    variable _client_socket _address _port _callback _retry_interval _retrying _scheduled_retry

    constructor {address port callback {retry_interval 500}} {
        set _address $address
        set _port $port
        set _callback $callback
        set _retry_interval $retry_interval
        set _retrying no
        my connect
    }

    destructor {
        catch {close $_client_socket}
        return
    }

    method connect {} {
        if {[catch {set _client_socket [socket $_address $_port]}]} {
            set _retrying yes
            set _scheduled_retry [after $_retry_interval [list [self] connect]]
        } else {
            set _retrying no
            chan configure $_client_socket -blocking no -buffering none -encoding iso8859-1 -translation binary
            chan event $_client_socket readable [list [self] read_data]
        }
    }

    method read_data {} {
        if {[chan eof $_client_socket]} {
            chan close $_client_socket
            if {!$_retrying} {
                my connect
            }
        } else {
            if {[catch {$_callback [chan read -nonewline $_client_socket]}]} {
                if {!$_retrying} {
                    my connect
                }
            }
        }
    }

    method send {message} {
        if {[catch {puts -nonewline $_client_socket $message}]} {
            if {!$_retrying} {
                my connect
            }
        }
    }
}