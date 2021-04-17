package require Tk
#package require platform_validator

wm title . "Bankroll Inspector"

grid [ttk::frame .frame -padding "20 20 20 20"] -column 0 -row 0 -sticky nsew
grid columnconfigure . .frame -weight 1

grid [ttk::frame .frame.bankroll -padding "2 2 2 2" -borderwidth 1 -relief sunken] -column 0 -row 0 -sticky nsew
grid columnconfigure .frame .frame.bankroll -weight 1
grid [ttk::label .frame.bankroll.version_label -padding "2 2 2 2" -text "Version" -relief sunken] -column 0 -row 0 -sticky nsew
grid columnconfigure .frame.bankroll .frame.bankroll.version_label -weight 1
grid [ttk::label .frame.bankroll.version_value -padding "2 2 2 2" -text "" -relief sunken] -column 1 -row 0 -sticky nsew
grid columnconfigure .frame.bankroll .frame.bankroll.version_value -weight 1
grid [ttk::label .frame.bankroll.balance_label -padding "2 2 2 2" -text "Balance" -relief sunken] -column 0 -row 1 -sticky nsew
grid columnconfigure .frame.bankroll .frame.bankroll.balance_label -weight 1
grid [ttk::label .frame.bankroll.balance_amount -padding "2 2 2 2" -text "" -relief sunken] -column 1 -row 1 -sticky nsew
grid columnconfigure .frame.bankroll .frame.bankroll.balance_amount -weight 1

grid [ttk::frame .frame.transaction -padding "2 2 2 2" -borderwidth 1 -relief sunken] -column 0 -row 2 -sticky nwes
grid columnconfigure .frame .frame.transaction -weight 1
grid [ttk::label .frame.transaction.amount_label -padding "2 2 2 2" -text "Transaction Amount" -relief sunken] -column 0 -row 0 -sticky nwes
grid columnconfigure .frame.transaction .frame.transaction.amount_label -weight 1
grid [ttk::entry .frame.transaction.amount_value -text "100" -textvariable transaction_amount] -column 1 -row 0 -sticky nwes
grid columnconfigure .frame.transaction .frame.transaction.amount_value -weight 1
grid [ttk::button .frame.transaction.deposit_button -padding "2 2 2 2" -text "Deposit" -command send_bankroll_deposit_request] -column 0 -row 1 -sticky nwes
grid columnconfigure .frame.transaction .frame.transaction.deposit_button -weight 1
grid [ttk::button .frame.transaction.debit_button -padding "2 2 2 2" -text "Debit" -command send_bankroll_debit_request] -column 1 -row 1 -sticky nwes
grid columnconfigure .frame.transaction .frame.transaction.debit_button -weight 1
grid [ttk::label .frame.transaction.status -padding "2 2 2 2" -text "" -relief sunken] -column 0 -row 2 -sticky nwes -columnspan 2
grid columnconfigure .frame.transaction .frame.transaction.status -weight 1

grid [ttk::frame .frame.lock -padding "2 2 2 2" -borderwidth 1 -relief sunken] -column 0 -row 4 -sticky nwes
grid columnconfigure .frame .frame.lock -weight 1
grid [ttk::label .frame.lock.status_label -padding "2 2 2 2" -text "Lock Status" -relief sunken] -column 0 -row 0 -sticky nwes
grid columnconfigure .frame.lock .frame.lock.status_label -weight 1
grid [ttk::label .frame.lock.status_value -padding "2 2 2 2" -text "" -relief sunken] -column 1 -row 0 -sticky nwes
grid columnconfigure .frame.lock .frame.lock.status_value -weight 1
grid [ttk::label .frame.lock.locker_label -padding "2 2 2 2" -text "Lock Holder Name" -relief sunken] -column 0 -row 1 -sticky nwes
grid columnconfigure .frame.lock .frame.lock.locker_label -weight 1
grid [ttk::entry .frame.lock.locker_value -text "bankroll_inspector" -textvariable lock_holder_name] -column 1 -row 1 -sticky nwes
grid columnconfigure .frame.lock .frame.lock.locker_value -weight 1
grid [ttk::button .frame.lock.lock_button -padding "2 2 2 2" -text "Lock" -command send_bankroll_lock_request] -column 0 -row 2 -sticky nwes
grid columnconfigure .frame.lock .frame.lock.lock_button -weight 1
grid [ttk::button .frame.lock.unlock_button -padding "2 2 2 2" -text "Unlock" -command send_bankroll_unlock_request] -column 1 -row 2 -sticky nwes
grid columnconfigure .frame.lock .frame.lock.unlock_button -weight 1
grid [ttk::label .frame.lock.status -padding "2 2 2 2" -text "" -relief sunken] -column 0 -row 3 -sticky nwes -columnspan 2
grid columnconfigure .frame.lock .frame.lock.status -weight 1

grid [ttk::label .frame.status] -column 0 -row 6 -sticky we
grid columnconfigure .frame .frame.status -weight 1

.frame.bankroll.version_value  configure -textvariable version
.frame.bankroll.balance_amount configure -textvariable balance
.frame.transaction.status      configure -textvariable transaction_status
.frame.lock.status_value       configure -textvariable lock_status
.frame.lock.status             configure -textvariable lock_request_status
.frame.status                  configure -textvariable status

bind . <Destroy> {set ::forever now}

set transaction_amount 100
set lock_holder_name bankroll_inspector

package require client
client create bankroll_inspector bankroll message_handler connected_callback

proc get_balance {} {

    catch {::send_bankroll_balance_request} result

    switch $result {

        {} {
            set ::status "Bankroll Connected"
            .frame.status configure -foreground blue
        }

        default {
            set ::status "Bankroll Unresponsive"
            .frame.status configure -foreground red
			set ::version ""
			set ::balance ""
			set ::transaction_status ""
			set ::lock_status ""
			set ::lock_request_status ""
        }
    }

    after 1000 get_balance
}

get_balance

proc connected_callback {} {
	::send_bankroll_meta_information_request
	::send_bankroll_lock_status_request
}

proc send_bankroll_balance_request {} {
	bankroll_inspector send [dict create   \
		sender bankroll_inspector          \
		receiver bankroll                  \
		summary {bankroll balance request} \
		details {}                         \
	]
}

proc send_bankroll_lock_status_request {} {
	bankroll_inspector send [dict create       \
		sender bankroll_inspector              \
		receiver bankroll                      \
		summary {bankroll lock status request} \
		details {}                             \
	]
}

proc send_bankroll_lock_request {} {
	bankroll_inspector send [dict create \
		sender $::lock_holder_name       \
		receiver bankroll                \
		summary {bankroll lock request}  \
		details {}                       \
	]
}

proc send_bankroll_unlock_request {} {
	bankroll_inspector send [dict create  \
		sender $::lock_holder_name        \
		receiver bankroll                 \
		summary {bankroll unlock request} \
		details {}                        \
	]
}

proc send_bankroll_deposit_request {} {
	bankroll_inspector send [dict create   \
		sender bankroll_inspector          \
		receiver bankroll                  \
		summary {bankroll deposit request} \
		details [dict create               \
			id [clock microseconds]        \
			type deposit                   \
			amount $::transaction_amount   \
		]
	]
}

proc send_bankroll_debit_request {} {
	bankroll_inspector send [dict create \
		sender bankroll_inspector        \
		receiver bankroll                \
		summary {bankroll debit request} \
		details [dict create             \
			id [clock microseconds]      \
			type debit                   \
			amount $::transaction_amount \
		]
	]
}

proc send_bankroll_meta_information_request {} {
	bankroll_inspector send [dict create            \
		sender bankroll_inspector                   \
		receiver bankroll                           \
		summary {bankroll meta information request} \
		details {}                                  \
	]
}

proc message_handler {message} {

	set sender   [dict get $message sender]
	set receiver [dict get $message receiver]
	set summary  [dict get $message summary]

	switch $summary {

		"bankroll meta information response" {
			set ::version [dict get $message details version]
		}

		"bankroll balance update" -
		"bankroll balance response" {
			set ::balance [dict get $message details balance]
		}

		"bankroll request response" {
			set ::transaction_status [dict get $message details]
		}

		"bankroll lock response" -
		"bankroll unlock response" {
			set ::lock_request_status [dict get $message details]
		}

		"bankroll locked" {set ::lock_status locked}
		"bankroll unlocked" {set ::lock_status unlocked}

	}
}
