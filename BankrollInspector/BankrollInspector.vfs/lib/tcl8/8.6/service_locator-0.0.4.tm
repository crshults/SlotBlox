package provide service_locator 0.0.4

package require udp
package require TclOO

oo::class create service_locator {

    variable _port _name _service_located_callback _scheduled_retry

    constructor {} {
        set _port [udp_open 15353 reuse]
        set _name unknown
        set _service_located_callback {}

        chan configure $_port           \
            -blocking  0                \
            -buffering none             \
            -mcastadd  {224.0.0.251}    \
            -mcastloop 1                \
            -remote    {224.0.0.251 15353}

        chan event $_port readable [list [self] handle_received_message]
    }

    destructor {
        catch {chan close $_port}
    }

	method handle_received_message {} {
		set message [chan read $_port]
        if {[string compare "service location $_name" [lrange $message 0 2]] eq 0} {
            set address  [lindex [chan configure $_port -peer] 0]
            set port [lindex $message end]
            catch {{*}$_service_located_callback [list $address $port]}
            after cancel $_scheduled_retry
        }
    }

    method find {name callback} {
        set _name $name
        set _service_located_callback $callback
        chan puts -nonewline $_port "service find $name"
        set _scheduled_retry [after 1000 [list [self] find $name $callback]]
    }

}
