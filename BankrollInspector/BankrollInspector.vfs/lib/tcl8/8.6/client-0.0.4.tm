package provide client 0.0.4
package require TclOO

oo::class create client {
    variable _client_socket _address _port _callback _retry_interval _scheduled_retry

    constructor {address port callback {retry_interval 500}} {
        set _address $address
        set _port $port
        set _callback $callback
        set _retry_interval $retry_interval
        my connect
    }

    destructor {
        after cancel $_scheduled_retry
        chan close $_client_socket
    }

    method connect {} {
        catch {chan close $_client_socket}
        set _client_socket [socket -async $_address $_port]
        chan configure $_client_socket -blocking no -buffering none -encoding iso8859-1 -translation binary
        chan event $_client_socket readable [list [self] read_data]
        chan event $_client_socket writable [list [self] connection_result]
    }

    method connection_result {} {
        if {[chan configure $_client_socket -error] != "" } {
            set _scheduled_retry [after 500 [list [self] connect]]
        }
        chan event $_client_socket writable {}
    }

    method read_data {} {
        if {[chan configure $_client_socket -error] == ""} {
            if {![catch {set message [chan read $_client_socket]}]} {
                if {[string length $message]} {
                    $_callback $message
                }
                if {[chan eof $_client_socket]} {
                    set _scheduled_retry [after 0 [list [self] connect]]
                }
            } else {
                set _scheduled_retry [after 0 [list [self] connect]]
            }
        }
    }

    method send {message} {
        catch {chan puts -nonewline $_client_socket $message}
        return
    }
}
