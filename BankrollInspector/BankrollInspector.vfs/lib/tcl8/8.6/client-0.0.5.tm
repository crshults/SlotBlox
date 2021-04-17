package require TclOO

oo::class create client {
    variable _client_socket _connected _address _port _callback

    constructor {address port callback} {
        set _address $address
        set _port $port
        set _callback $callback
        my connect
    }

    destructor {
        catch {chan close $_client_socket}
    }

    method connect {} {
        catch {chan close $_client_socket}
        set _connected no
        set _client_socket [socket -async $_address $_port]
        chan configure $_client_socket -blocking no -buffering none -encoding iso8859-1 -translation binary
        chan event $_client_socket readable [list [self] read_data]
        chan event $_client_socket writable [list [self] connection_result]
    }

    method connection_result {} {
        if {[chan configure $_client_socket -error] == "" } {
            set _connected yes
        }
        chan event $_client_socket writable {}
    }
    
    method read_data {} {
        if {[chan configure $_client_socket -error] != "" } {
            my connect
            return
        }

        if {[catch {set message [chan read $_client_socket]}]} {
            my connect
            return
        }

        if {[string length $message]} {
            $_callback $message
        }

        if {[chan eof $_client_socket]} {
            my connect
            return
        }
    }

    method send {message} {
        if {$_connected} {
            if {[catch {chan puts -nonewline $_client_socket $message}]} {
                my connect
                error "client not connected"
            }
        } else {
            error "client not connected"
        }
    }
}
