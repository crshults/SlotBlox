package require client
package require server
package require web_server
package require system_information
#package require platform_validator

web_server create      \
	flipper_web_server \
	message_handler

client create                  \
	flipper                    \
	display                    \
	message_handler            \
	docked_to_display_handler

server create                          \
	flipper_front_dock                 \
	flipper_front_dock_message_handler \
	front_undocked_handler

client create                  \
	bankroll                   \
	bankroll                   \
	message_handler            \
	bankroll_connected_handler \
	bankroll_disconnected_handler

proc ip_address_known_callback {} {

    set    ::content_address http://${system_information::ip_address}
    append ::content_address :[flipper_web_server port]
}

proc message_handler {message {client unknown}} {

	if {![dict exists $message sender]}   return
	if {![dict exists $message receiver]} return
	if {![dict exists $message summary]}  return
	if {![dict exists $message details]}  return

	set sender   [dict get $message sender]
	set receiver [dict get $message receiver]
	set summary  [dict get $message summary]
	set details  [dict get $message details]

	switch $summary {

		"user interface available" {

			flipper_front_dock broadcast [dict create \
				sender   flipper                      \
				receiver content_provider             \
				summary  "request content"            \
				details  {}                           \
			]

			flipper_back_dock  broadcast [dict create \
				sender   flipper                      \
				receiver content_provider             \
				summary  "request content"            \
				details  {}                           \
			]

			# In the case where there is no docked game, we would still like the
			# user to be able to see their current bankroll balance, so we fire
			# off a request to the bankroll to get the current balance.
			#

			catch {

				bankroll send [dict create              \
					sender   multigamemenu              \
					receiver bankroll                   \
					summary  "bankroll balance request" \
					details  {}                         \
				]
			}
		}

		"request content" {

			send_load_content_message
		}

		"bankroll available" {

			bankroll send [dict create              \
				sender   flipper                    \
				receiver bankroll                   \
				summary  "bankroll balance request" \
				details  {}                         \
			]

			return
		}

		"bankroll unavailable" {

			flipper_web_server send [dict create \
				sender   flipper_backend         \
				receiver flipper_frontend        \
				summary  "clear credit meter"    \
				details  {}                      \
			]

			return
		}

		"bankroll balance response" -
		"bankroll balance update" {

			set balance [dict get $message details balance]

			flipper_web_server send [dict create \
				sender   flipper_backend         \
				receiver flipper_frontend        \
				summary  "set credit meter"      \
				details  [dict create            \
					value $balance               \
					{}    {}                     \
				]                                \
			]
		}
	}
}

proc docked_to_display_handler {} {

	send_load_content_message
}

proc send_load_content_message {} {

	flipper send [dict create          \
		sender   flipper               \
		receiver display               \
		summary  "load content"        \
		details  [dict create          \
			address $::content_address \
			{}      {}                 \
		]                              \
	]
}

proc flipper_front_dock_message_handler {message client} {

	set sender   [dict get $message sender]
	set receiver [dict get $message receiver]
	set summary  [dict get $message summary]
	set details  [dict get $message details]

	switch $summary {

		"load content" {

			set address [dict get $details address]

			flipper_web_server send [dict create \
				sender   flipper_backend         \
				receiver flipper_frontend        \
				summary  "load front content"    \
				details  [dict create            \
					address $address             \
					{}      {}                   \
				]                                \
			]
		}
	}
}

proc front_undocked_handler {_} {

	flipper_web_server send [dict create \
		sender   flipper_backend         \
		receiver flipper_frontend        \
		summary  "hide front content"    \
		details  {}                      \
	]
}

server create                         \
	flipper_back_dock                 \
	flipper_back_dock_message_handler \
	back_undocked_handler

proc flipper_back_dock_message_handler {message client} {

	set sender   [dict get $message sender]
	set receiver [dict get $message receiver]
	set summary  [dict get $message summary]
	set details  [dict get $message details]

	switch $summary {

		"load content" {

			set address [dict get $details address]

			flipper_web_server send [dict create \
				sender   flipper_backend         \
				receiver flipper_frontend        \
				summary  "load back content"     \
				details  [dict create            \
					address $address             \
					{}      {}                   \
				]                                \
			]
		}
	}
}

proc back_undocked_handler {_} {

	flipper_web_server send [dict create \
		sender   flipper_backend         \
		receiver flipper_frontend        \
		summary  "hide back content"     \
		details  {}                      \
	]
}

proc bankroll_connected_handler {} {

	message_handler [dict create      \
		sender   flipper              \
		receiver flipper              \
		summary  "bankroll available" \
		details  {}                   \
	]
}

proc bankroll_disconnected_handler {} {

	message_handler [dict create        \
		sender   flipper                \
		receiver flipper                \
		summary  "bankroll unavailable" \
		details  {}                     \
	]
}
