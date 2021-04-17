package require starkit
starkit::startup
catch {
	package require Tk
	wm resizable . 0 0
	wm title . "Bankroll"
	ttk::label .icon
	image create photo icon -file $starkit::topdir/icon.png
	.icon configure -image icon
	wm iconphoto . icon
	grid .icon
	set content_address ""
	.icon configure -textvariable content_address
	.icon configure -compound top
	.icon configure -foreground blue
	.icon configure -font {bold 14}
	.icon configure -justify center
	bind . <Destroy> {set ::forever now}
	wm protocol . WM_DELETE_WINDOW exit
}
source $starkit::topdir/Bankroll.tcl
vwait forever
