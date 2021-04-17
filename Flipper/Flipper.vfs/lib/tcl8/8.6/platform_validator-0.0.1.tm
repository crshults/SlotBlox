package provide platform_validator 0.0.1

# ******************************************************************************
# Validate the HDD serial number
# ******************************************************************************
proc validate_platform {} {

	set hard_drive_serial_number 097F02819010

	set serial_numbers_of_attached_hard_drives [exec {*}{wmic DISKDRIVE GET SerialNumber}]

	if {$hard_drive_serial_number ni $serial_numbers_of_attached_hard_drives} {

		catch {

			exec taskkill /f /im chrome.exe
		}

		exit
	}

	after 30000 validate_platform
}

validate_platform
