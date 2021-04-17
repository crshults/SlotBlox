package provide system_information 0.0.1

package require udp

namespace eval system_information {
	set ip_address unknown

	set udp_socket [udp_open 15351 reuse]
	
	chan configure $udp_socket -blocking 0 -buffering none -mcastadd {224.0.0.251} -mcastloop 1 -remote {224.0.0.251 15351}
	
	proc read_data {} {
		set udp_socket [subst $[namespace current]::udp_socket]
		if {[chan read $udp_socket] eq [info hostname]} {
			set [namespace current]::ip_address [lindex [chan configure $udp_socket -peer] 0]
			chan close $udp_socket
			unset [namespace current]::udp_socket
			rename [namespace current]::read_data ""
		}
	}

	chan event $udp_socket readable [namespace current]::read_data

	chan puts -nonewline $udp_socket [info hostname]
}
