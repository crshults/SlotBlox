# ******************************************************************************
# MIT License
# 
# Copyright © 2021 Chris Shults
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# ******************************************************************************
# * The system_info library is a Tcl module that allows you to automatically
# * discover the IP Address of the machine you are currently running on.
# *

package provide system_info 0.1.0

namespace eval system_info {}

# ******************************************************************************
# * On the Windows platform, use the ipconfig command to get all the system IP
# * Addresses
# *
if {![catch {exec ipconfig} ipconfig_output]} {

	# Each IPv4 Addresses will be ranked according to how many IPv6 Addresses it
	# is accompanied by
	set ranked_ip_addresses [list]

	foreach match [regexp -all -inline {IPv4 Address[. :]+\d+.\d+.\d+.\d+|IPv6 Address[. :]+[\w%:]+} $ipconfig_output] {

		if {[lindex $match 0] eq "IPv6"} {

			incr ipv6_count

		} else {

			lappend ranked_ip_addresses [list [lindex $match end] $ipv6_count]
			set ipv6_count 0
		}
	}

	set system_info::ip_addresses [
		lmap ranked_ip [
			lsort -integer -decreasing -index 1 $ranked_ip_addresses
		] {
			lindex $ranked_ip 0
		}
	]

	unset ranked_ip_addresses
	unset ipv6_count
}

# ******************************************************************************
# * On the Linux platform, use the ifconfig command to get all the system IP
# * Addresses
# *
# * Note: We will also need a version that does the [ip a] command because new
# * Linux systems no longer have the ifconfig command since it is being
# * deprecated
# *
if {![catch {exec ifconfig} ifconfig_output]} {

	set ranked_ip_addresses [list]

	foreach match [regexp -all -inline {inet \d+.\d+.\d+.\d+|inet6 [\w%:]+} $ifconfig_output] {

		if {[lindex $match 0] eq "inet"} {

			set ipv6_count 0
			lappend ranked_ip_addresses [list [lindex $match end] $ipv6_count]

		} else {

			incr ipv6_count
			lset ranked_ip_addresses end end $ipv6_count
		}
	}

	set ranked_ip_addresses [
		lsearch -all -inline -not -exact -index 0 $ranked_ip_addresses 127.0.0.1
	]

	set system_info::ip_addresses [lmap ranked_ip [lsort -integer -decreasing -index 1 $ranked_ip_addresses]  {lindex $ranked_ip 0}]

	unset ranked_ip_addresses
	unset ipv6_count
}

set system_info::broadcast_addresses [
	lmap ip_address $system_info::ip_addresses {
		join [lreplace [split $ip_address .] end end 255] .
	}
]

lappend system_info::ip_addresses 127.0.0.1
