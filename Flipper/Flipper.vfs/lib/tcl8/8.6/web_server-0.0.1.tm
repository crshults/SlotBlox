package provide web_server 0.0.1

package require sha1
package require TclOO
package require client
package require server
package require sqlite3
package require textutil
package require list_tools
package require binary_tools

oo::class create web_server {

	variable _server_socket _content_types _callback _real_time_channel

	constructor {callback {port 0}} {

		set _content_types [dict create    \
			.html text/html                \
			.css  text/css                 \
			.js   application/x-javascript \
			.ogg  application/ogg          \
			.ttf  application/x-font-ttf   \
			.otf  application/x-font-ttf   \
			.jpg  image/jpeg               \
			.png  image/png                \
			.gif  image/gif                \
			.ico  image/x-icon             \
			.webm video/webm               \
		]

		set _server_socket [socket -server [list [self] accept_connection] $port]

		set _callback $callback
	}

	destructor {

		chan close $_server_socket
	}

	method port {} {

		lindex [chan configure $_server_socket -sockname] end
	}

	method accept_connection {channel address port} {

		chan configure $channel \
			-blocking    no     \
			-buffering   none   \
			-encoding    binary \
			-translation binary

		chan event $channel readable [list [self] read_data $channel]
	}

	method read_data {channel} {

		if {[catch {set data [chan read $channel]}]} {

			chan close $channel
			return
		}

		if {[chan eof $channel]} {

			chan close $channel
			return
		}

		set request_lines [regexp -all -inline {[^\r\n]+} $data]

		dict set message channel $channel

		lassign [lindex $request_lines 0] method request_target http_version

		dict set message request start_line method         $method
		dict set message request start_line request_target $request_target
		dict set message request start_line http_version   $http_version

		foreach header [lrange $request_lines 1 end] {

			dict set message request headers {*}[textutil::splitx $header ": "]
		}

		if {[dict exists $message request headers Sec-WebSocket-Key]} {

			set key [dict get $message request headers Sec-WebSocket-Key]

			append response "HTTP/1.1 101 Switching Protocols" "\n"
			append response "Upgrade: websocket"               "\n"
			append response "Connection: Upgrade"              "\n"
			append response "Sec-WebSocket-Accept: [binary encode base64 [sha1::sha1 -bin ${key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11]]" "\n"

			chan puts $channel $response

			chan event $channel readable [list [self] read_websocket_data $channel]

			set _real_time_channel $channel

		} else {

			if {$request_target eq "/"} {

				set request_target "/index.html"
			}

			set resource $starkit::topdir/content$request_target

			if {[catch {set filehandle [open $resource rb]} result]} {

				chan close $channel
				return
			}

			set currenttime [clock format [clock seconds] -gmt 1 -format {%a, %d %h %Y %T %Z}]

			append response "HTTP/1.1 200 OK"                                                     "\n"
			append response "Content-Length: [file size $resource]"                               "\n"
			append response "Content-Type: [dict get $_content_types [file extension $resource]]" "\n"
			append response "Last-Modified: $currenttime"                                         "\n"
			append response "Date: $currenttime"                                                  "\n"
			append response "\n"
			append response [chan read $filehandle]

			chan close $filehandle

			chan puts -nonewline $channel $response
		}
	}

    method read_websocket_data {channel} {

		if {[catch {set received_message [chan read $channel]}]} {

			chan close $channel
			my report_connection_loss
			return
		}

		if {[chan eof $channel]} {

			chan close $channel
			my report_connection_loss
			return
		}

		while {[string length $received_message] > 0} {

			set received_message [bassign $received_message {fin 1 rsv1 1 rsv2 1 rsv3 1 opcode 4 mask 1 payload_length 7}]

			if {$rsv1 || $rsv2 || $rsv3} {

				chan close $channel
				my report_connection_loss
				return
			}

			if {$opcode eq "8"} {

				chan close $channel
				my report_connection_loss
				return
			}

			switch $payload_length {

				0   return
				126 {set received_message [bassign $received_message {payload_length 16}]}
				127 {set received_message [bassign $received_message {payload_length 64}]}
			}

			binary scan $received_message c1c1c1c1c$payload_length masking_key(0) masking_key(1) masking_key(2) masking_key(3) payload

			set received_message [string range $received_message [expr {$payload_length+4}] end]

			for {set i 0} {$i < $payload_length} {incr i} {

				append message [binary format c1 [expr {[lindex $payload $i] ^ $masking_key([expr $i % 4])}]]
			}

			if {$opcode eq "9"} {

				chan puts -nonewline $channel \x8a[binary format H* [format %02x $payload_length]]$message
				return
			}

			$_callback $message
		}
	}

	method report_connection_loss {} {

		$_callback [dict create                  \
			sender   web_server                  \
			receiver web_server_creator          \
			summary  "real time connection lost" \
			details  {}                          \
		]
	}

	method send {message} {

		set length [string length $message]

		if {$length < 126} {

			set message \x81[binary format H* [format %02x $length]]$message

		} elseif {$length < 65536} {

			set message \x81\x7e[binary format H* [format %04x $length]]$message

		} else {

			#client will close the connection if you try to send a single message this big
			set message \x81\x7f[binary format H* [format %08x $length]]$message
		}

		catch {

			chan puts -nonewline $_real_time_channel $message
		}
	}
}
