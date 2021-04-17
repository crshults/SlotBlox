package require TclOO
package require platform
package require list_tools

proc get_process_ids {} {

    foreach process [lrange [split [exec ps -e] \n] 1 end] {

        lappend process_ids [lindex $process 0]
    }

    return $process_ids
}

oo::class create serial_port {
    variable _port_name _port _baud_rate _data_bits _parity _system_serial_ports

    constructor {baud_rate parity {data_bits 8}} {
        set _baud_rate $baud_rate
        set _parity $parity
        set _data_bits $data_bits
        set _system_serial_ports [my AvailableSerialPortList]
        my open
    }

    destructor {
        my close
    }

    method open {} {
        my close
        set _port_name [my GetNextSerialPort]

		set platform [lindex [split [platform::generic] -] 0]
		puts "serial_port open $platform"

		if {$platform eq "linux"} {
			puts "inside the if..."
			set device_name    [file tail $_port_name]
			set lock_file_name /var/lock/LCK..$device_name
			set file_handle     [open $lock_file_name {RDWR CREAT}]
			set lock_holder_pid [chan gets $file_handle]
			if {[lcontains [get_process_ids] $lock_holder_pid]} {
				# the current lock holder is still alive so we will move on
				# should find a way to skip to the next, but we were having
				# problems before with the recursive open call
				chan close $file_handle
				return
			} else {
				chan truncate $file_handle
				chan seek $file_handle 0
				chan puts $file_handle [pid]
				chan close $file_handle
			}
		}

        catch {set _port [open $_port_name r+]}
        catch {chan configure $_port       \
            -blocking 0                    \
            -buffering none                \
            -encoding binary               \
            -translation {binary binary}   \
            -mode $_baud_rate,$_parity,$_data_bits,1 \
            -pollinterval 1}
        return
    }

    method close {} {
        catch {
            chan close $_port
            set _port ""
            set device_name    [file tail $_port_name]
            set lock_file_name /var/lock/LCK..$device_name
            file delete -force $lock_file_name
        }
        return
    }

    method send {message} {
        catch {chan puts -nonewline $_port $message}
        return
    }

    method read {} {
        if {[catch {set response [chan read $_port]}]} {
            return
        } else {
            return $response
        }
    }

    method port_name {} {
        return $_port_name
    }
    
    method parity {new_setting} {
        set _parity $new_setting
        catch {chan configure $_port -mode $_baud_rate,$_parity,$_data_bits,1}
        return
    }

    method data_bits {new_setting} {
        set _data_bits $new_setting
        catch {chan configure $_port -mode $_baud_rate,$_parity,$_data_bits,1}
        return
    }

    method AvailableSerialPortList {} {
        set port_list {}
        set platform [lindex [split [platform::generic] -] 0]

        switch -- $platform {
            win32 {
                package require registry
                set SerialCommKey {HKEY_LOCAL_MACHINE\Hardware\DeviceMap\SerialComm}
                catch {
                    foreach port [registry values $SerialCommKey] {
                        lappend port_list //./[registry get $SerialCommKey $port]
                    }
                }
            }

            linux {
                set port_list [glob -nocomplain {/dev/ttyS[0-9]} {/dev/ttyUSB[0-9]}]
            }
        }

        return $port_list
    }

    method GetNextSerialPort {} {
        if {[llength [my AvailableSerialPortList]] != [llength $_system_serial_ports]} {
            set _system_serial_ports [my AvailableSerialPortList]
        } else {
            lrotate _system_serial_ports
        }
        return [lindex $_system_serial_ports 0]
    }
}
