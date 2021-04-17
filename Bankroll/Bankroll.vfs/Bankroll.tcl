package require server
package require sqlite3
#package require platform_validator

sqlite3 db bankroll.sqlite

db eval {
	CREATE TABLE IF NOT EXISTS Configuration(
		ConfigurationId INTEGER PRIMARY KEY CHECK (ConfigurationId = 1),
		Name            TEXT    DEFAULT 'bankroll',
		Version         TEXT    DEFAULT '0.0.1',
		MaxLogEntries   INTEGER DEFAULT 1000000
	);

	INSERT OR IGNORE INTO Configuration DEFAULT VALUES;

	pragma table_info(Configuration);
} {
	eval {
		proc get_$name {} [
			list db eval [
				list SELECT $name FROM Configuration;
			]
		]
	}
}

db eval {
	CREATE TABLE IF NOT EXISTS Accounts(
		AccountId      INTEGER PRIMARY KEY CHECK (AccountId = 1),
		BalanceInCents INTEGER CHECK ( BalanceInCents >= 0 ) DEFAULT 0,
		LockHolder     TEXT    DEFAULT 'none'
	);

	INSERT OR IGNORE INTO Accounts DEFAULT VALUES;

	pragma table_info(Accounts);
} {
	eval {
		proc get_$name {} "join \[db eval \{SELECT $name FROM Accounts;\}\]"
	}
}

proc set_LockHolder {lock_holder} {
	db eval {
		UPDATE Accounts
		   SET LockHolder = $lock_holder;
	}
}

db eval {
	CREATE TABLE IF NOT EXISTS TransactionLog(
		LogIndex        INTEGER PRIMARY KEY,
		TransactionId   INTEGER UNIQUE,
		TransactionType TEXT,
		AmountInCents   INTEGER,
		Requester       TEXT,
		Status          TEXT    DEFAULT incomplete
	);

	pragma table_info(TransactionLog);
} {
	eval {
		proc get_$name {transaction_id} [
			list db eval "
				SELECT $name \
				  FROM TransactionLog \
				 WHERE TransactionId = \$transaction_id;
			"
		]
	}
}

proc get_MaxLogIndex {} {
	db eval {
		SELECT LogIndex
		  FROM TransactionLog
		 WHERE TransactionId = (SELECT MAX(TransactionId) FROM TransactionLog);
	}
}

proc get_NextLogIndex {} {
	switch [set log_index [get_MaxLogIndex]] {
		""      {return 0}
		default {return [expr {[incr log_index] % [get_MaxLogEntries]}]}
	}
}

proc create_TransactionLogEntry {transaction_id transaction_type amount_in_cents requester} {
	set log_index [get_NextLogIndex]

	db eval {
		INSERT OR REPLACE INTO TransactionLog (LogIndex, TransactionId, TransactionType, AmountInCents, Requester)
						VALUES ($log_index, $transaction_id, $transaction_type, $amount_in_cents, $requester);
	}
}

proc doesTransactionLogEntryExist {transaction_id} {
	switch [get_TransactionId $transaction_id] {
		""      {return no}
		default {return yes}
	}
}

proc completeTransaction {transaction_id} {
	set balance_in_cents [get_BalanceInCents]

	switch [get_TransactionType $transaction_id] {
		deposit {incr balance_in_cents [get_AmountInCents $transaction_id]}
		debit   {incr balance_in_cents -[get_AmountInCents $transaction_id]}
	}

	db transaction immediate {
		catch {
			db eval {
				UPDATE Accounts
				   SET BalanceInCents = $balance_in_cents;

				UPDATE TransactionLog
				   SET Status = 'complete'
				 WHERE TransactionId = $transaction_id;
			}
		} result

		if {$result ne ""} {
			db eval {
				UPDATE TransactionLog
				   SET Status = 'failed'
				 WHERE TransactionId = $transaction_id;
			}
		}
	}
}

server create bankroll message_handler

proc message_handler {message {client {}}} {

	set sender   [dict get $message sender]
	set receiver [dict get $message receiver]
	set summary  [dict get $message summary]

	switch $summary {

		"bankroll deposit request" -
		"bankroll debit request" {

			if {[get_LockHolder] ne "none" && [get_LockHolder] ne $sender} {

				bankroll send $client [dict create      \
					sender bankroll                     \
					receiver $sender                    \
					summary "bankroll request response" \
					details [dict create                \
						status "failed"                 \
						reason "missing lock"           \
					]
				]

				return
			}

			set transaction_id   [dict get $message details id]
			set transaction_type [dict get $message details type]
			set amount_in_cents  [dict get $message details amount]

			if {[doesTransactionLogEntryExist $transaction_id] eq "no"} {
				create_TransactionLogEntry $transaction_id $transaction_type $amount_in_cents $sender
			}

			if {[get_Status $transaction_id] eq "incomplete"} {

				completeTransaction $transaction_id

				if {[get_Status $transaction_id] eq "complete"} {

					bankroll broadcast [dict create                   \
						sender bankroll                               \
						receiver all                                  \
						summary "bankroll balance update"             \
						details [dict create                          \
							balance   [get_BalanceInCents]            \
							requester [get_Requester $transaction_id] \
						]
					]
				}
			}

			bankroll send $client [dict create          \
				sender bankroll                         \
				receiver $sender                        \
				summary "bankroll request response"     \
				details [dict create                    \
					id     $transaction_id              \
					type   $transaction_type            \
					amount $amount_in_cents             \
					status [get_Status $transaction_id] \
				]
			]
		}

		"bankroll lock status request" {

			if {[get_LockHolder] eq "none"} {

				bankroll send $client [dict create \
					sender bankroll                \
					receiver $sender               \
					summary "bankroll unlocked"    \
					details {}                     \
				]

			} else {

				bankroll send $client [dict create \
					sender bankroll                \
					receiver $sender               \
					summary "bankroll locked"      \
					details {}                     \
				]
			}
		}

		"bankroll lock request" {

			if {[get_LockHolder] eq "none" || [get_LockHolder] eq $sender} {

				set_LockHolder $sender

				bankroll send $client [dict create   \
					sender bankroll                  \
					receiver $sender                 \
					summary "bankroll lock response" \
					details [dict create             \
						status "success"             \
					]
				]

				bankroll broadcast [dict create \
					sender bankroll             \
					receiver all                \
					summary "bankroll locked"   \
					details {}                  \
				]

			} else {

				bankroll send $client [dict create   \
					sender bankroll                  \
					receiver $sender                 \
					summary "bankroll lock response" \
					details [dict create             \
						status "failure"             \
						reason "missing lock"        \
					]
				]
			}
		}

		"bankroll unlock request" {

			if {[get_LockHolder] eq "none" || [get_LockHolder] eq $sender} {

				set_LockHolder none

				bankroll send $client [dict create     \
					sender bankroll                    \
					receiver $sender                   \
					summary "bankroll unlock response" \
					details [dict create               \
						status "success"               \
					]
				]

				bankroll broadcast [dict create \
					sender bankroll             \
					receiver all                \
					summary "bankroll unlocked" \
					details {}                  \
				]

			} else {

				bankroll send $client [dict create     \
					sender bankroll                    \
					receiver $sender                   \
					summary "bankroll unlock response" \
					details [dict create               \
						status "failure"               \
						reason "missing lock"          \
					]
				]
			}
		}

		"bankroll balance request" {

			bankroll send $client [dict create      \
				sender bankroll                     \
				receiver $sender                    \
				summary "bankroll balance response" \
				details [dict create                \
					balance [get_BalanceInCents]    \
				]
			]
		}

		"bankroll meta information request" {

			bankroll send $client [dict create               \
				sender bankroll                              \
				receiver $sender                             \
				summary "bankroll meta information response" \
				details [dict create                         \
					name [get_Name]                          \
					version [get_Version]                    \
				]
			]
		}
	}
}

proc ip_address_known_callback {} {

	# Once we know the ip address of the machine we are currently running on,
	# we give the full address that users will be able to use in order to
	# make HTTP requests for the contents of this starpack.
	#

	set    ::content_address http://${system_information::ip_address}
	append ::content_address :[ticktackdough_web_server port]
}