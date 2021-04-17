package require starkit
package require tooltip

starkit::startup

catch {
	package require Tk
	package require platform

	proc launch_browser {} {

		if {$::content_address eq ""} return

		set platform [lindex [split [platform::generic] -] 0]

		switch -- $platform {

			win32 {

				catch {
					exec {*}[auto_execok start] $::content_address &
				}
			}

			linux {

				catch {
					exec xdg-open $::content_address &
				}
			}
		}
	}

	wm resizable . 0 0
	wm title . "Flipper"
	ttk::label .icon
	image create photo icon -file $starkit::topdir/icon.png
	.icon configure -image icon
	ttk::label .version_sticker -text 0.0 -anchor center -font {-weight bold -size 10} -background red -foreground white
	wm iconphoto . icon
	grid .icon
	place .version_sticker -x 176 -y 186 -width 32 -height 18
	set content_address ""
	.icon configure -textvariable content_address
	.icon configure -compound top
	.icon configure -foreground blue
	.icon configure -font {bold 14}
	.icon configure -justify center
	bind .icon <Button-1> launch_browser
	bind .version_sticker <Button-1> launch_browser
	tooltip::tooltip .icon "Click anywhere to launch the content in your browser,\nor visit the displayed address from your mobile device."
	tooltip::tooltip .version_sticker "Click anywhere to launch the content in your browser,\nor visit the displayed address from your mobile device."
	bind . <Destroy> {set ::forever now}
	wm protocol . WM_DELETE_WINDOW exit
}

source $starkit::topdir/Flipper.tcl
vwait forever
