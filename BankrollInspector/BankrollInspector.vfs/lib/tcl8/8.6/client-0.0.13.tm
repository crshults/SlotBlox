package provide client 0.0.13

package require TclOO
package require service_locator

oo::class create client {
    variable _client_socket _connected _address _port _callback
    variable _awaiting_connection_result _connected_callback
    variable _service_locator _service_name

    constructor {service_name callback {connected_callback {}}} {
        set _service_name $service_name
        set _address unknown
        set _port unknown
        set _callback $callback
        set _connected_callback $connected_callback
        set _service_locator [service_locator new]
        after idle [list [self] find_service]
    }

    destructor {
        catch {chan close $_client_socket}
        $_service_locator destroy
    }

    method find_service {} {
        catch {chan close $_client_socket}
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
        chan configure $_client_socket -blocking no -buffering line -encoding iso8859-1 -translation binary
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
