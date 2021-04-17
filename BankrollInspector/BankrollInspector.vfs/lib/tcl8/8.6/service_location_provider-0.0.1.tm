package require udp
package require TclOO
package require system_information

oo::class create service_location_provider {

    variable _port _name _scope _address

    constructor {name scope address} {

        if {$scope ni {local global}} {
            error "scope must be {local} or {global}"
        }

        set _port [udp_open 15353 reuse]
        set _name $name
        set _scope $scope
        set _address $address

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
        set my_ip_address $::system_information::ip_address
        set sender_ip_address [lindex [chan configure $_port -peer] 0]

        if {$_scope eq "local" && $sender_ip_address ne $my_ip_address} {
            return
        }

        if {$message eq "service find $_name"} {
            chan puts -nonewline $_port "service location $_name $_address"
        }
    }

}
