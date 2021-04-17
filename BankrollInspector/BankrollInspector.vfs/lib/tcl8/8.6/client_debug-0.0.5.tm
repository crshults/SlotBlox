package require TclOO

oo::class create client {
    variable _client_socket _connected _address _port _callback

    constructor {address port callback} {
		puts "    client constructor"
        set _address $address
        set _port $port
        set _callback $callback
        my connect
    }

    destructor {
	    puts "    client destructor"
        catch {chan close $_client_socket}
    }

    method connect {} {
		puts ""
	    puts "    client connect"
        catch {chan close $_client_socket}
        set _connected no
        set _client_socket [socket -async $_address $_port]
        chan configure $_client_socket -blocking no -buffering none -encoding iso8859-1 -translation binary
        chan event $_client_socket readable [list [self] read_data]
        chan event $_client_socket writable [list [self] connection_result]
    }

    method connection_result {} {
	    puts -nonewline "    client connection_result: "
        puts [set connection_result [chan configure $_client_socket -error]]
        if {$connection_result == "" } {
            set _connected yes
        }
        chan event $_client_socket writable {}
    }
    
    method read_data {} {
	    puts -nonewline "    client read_data: "
		set connection_result [chan configure $_client_socket -error]
        if {$connection_result != "" } {
			puts "connection_result: $connection_result"
            my connect
            return
        }

        if {[catch {set message [chan read $_client_socket]}]} {
			puts "caught error reading"
            my connect
            return
        }

        if {[string length $message]} {
            $_callback $message
        }

        if {[chan eof $_client_socket]} {
			puts "chan eof"
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
