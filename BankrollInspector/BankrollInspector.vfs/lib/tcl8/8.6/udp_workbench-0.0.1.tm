package require udp

set udp_socket [udp_open 15351 reuse]
chan configure $udp_socket -blocking 0 -buffering none -mcastadd {224.0.0.251} -mcastloop 1 -remote {224.0.0.251 15351}

proc read_data {} {
	puts [chan read $::udp_socket]
}

chan event $udp_socket readable read_data

proc send_ping {} {
	chan puts -nonewline $::udp_socket ping
}
