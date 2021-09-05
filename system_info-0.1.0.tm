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

# Clean up any old information that may still exist
catch {unset system_info::ip_addresses}
catch {unset system_info::broadcast_addresses}

namespace eval system_info {}

# Initialize the ip address list in case we find no other addresses besides the
# localhost address.
set system_info::ip_addresses [list]

# ******************************************************************************
# * On the Windows platform, use the ipconfig command to get all the system IP
# * Addresses
# *
if {![catch {exec ipconfig} ipconfig_output]} {

	# Each IPv4 Addresses will be ranked according to how many IPv6 Addresses it
	# is accompanied by.
	set ranked_ip_addresses [list]
	set ipv6_count 0

	# Extract all the lines from the ipconfig output that contain IPv4 or IPv6
	# addresses
	foreach match [
		regexp -all -inline \
			{IPv4 Address[. :]+[\d+.]+|IPv6 Address[. :]+[\w%:]+} \
			$ipconfig_output
	] {

		if {[lindex $match 0] eq "IPv6"} {

			# In the ipconfig output, the IPv6 addresses come before the IPv4
			# addresses, so as we loop through all the address lines from the
			# ipconfig output, keep a counter of how many IPv6 addresses are
			# found
			incr ipv6_count

		} else {

			# Once we reach the IPv4 line of the ipconfig output, append the
			# IPv4 address along with the preceding IPv6 address count to a
			# list. The number of IPv6 addresses accompanying an IPv4 address is
			# considered its "rank" and will be used for sorting purposes. Reset
			# the IPv6 counter now.
			lappend ranked_ip_addresses [list [lindex $match end] $ipv6_count]
			set ipv6_count 0
		}
	}

	# Sort the list of ranked IPv4 addresses by rank from highest to lowest.
	# Then strip out the ranks leaving a list of IPv4 addresses.
	set system_info::ip_addresses [
		lmap ranked_ip [
			lsort -integer -decreasing -index 1 $ranked_ip_addresses
		] {
			lindex $ranked_ip 0
		}
	]

	# Clean up all temporary variables
	unset ranked_ip_addresses
	unset ipv6_count
}

# ******************************************************************************
# * On the Mac platform, use the ifconfig command to get all the system IP
# * Addresses (also works on platforms where net-tools is installed)
# *
if {![catch {exec ifconfig} ifconfig_output]} {

	# Each IPv4 Addresses will be ranked according to how many IPv6 Addresses it
	# is accompanied by.
	set ranked_ip_addresses [list]
	set inet6_count 0

	# Extract all the lines from the ipconfig output that contain IPv4 or IPv6
	# addresses
	foreach match [
		regexp -all -inline \
			{inet \d+.\d+.\d+.\d+|inet6 [\w%:]+} \
			$ifconfig_output
	] {

		if {[lindex $match 0] eq "inet"} {

			# In the ifconfig output, the inet addresses come before the inet6
			# addresses, so as we loop through all the address lines from the
			# ifconfig output, append the inet addresses to the list with an
			# initial rank of 0
			set inet6_count 0
			lappend ranked_ip_addresses [list [lindex $match end] $inet6_count]

		} else {

			# As we find inet6 addresses, increment their count and update the
			# rank value of the associated inet address.
			incr inet6_count
			lset ranked_ip_addresses end end $inet6_count
		}
	}

	# Strip out the localhost address. We do not want it in our list yet.
	set ranked_ip_addresses [
		lsearch -all -inline -not -exact -index 0 $ranked_ip_addresses 127.0.0.1
	]

	# Sort the list of ranked IPv4 addresses by rank from highest to lowest.
	# Then strip out the ranks leaving a list of IPv4 addresses.
	set system_info::ip_addresses [
		lmap ranked_ip [
			lsort -integer -decreasing -index 1 $ranked_ip_addresses
		]  {
			lindex $ranked_ip 0
		}
	]

	# Clean up all temporary variables
	unset ranked_ip_addresses
	unset inet6_count
}

# ******************************************************************************
# * On the Linux platform, use the ip address command to get all the system IP
# * Addresses
# *
if {![info exists system_info::ip_addresses]} {

	if {![catch {exec ip address} ip_address_output]} {

		# Each IPv4 Addresses will be ranked according to how many IPv6
		# Addresses it is accompanied by.
		set ranked_ip_addresses [list]
		set inet6_count 0

		# Extract all the lines from the ipconfig output that contain IPv4 or
		# IPv6 addresses
		foreach match [
			regexp -all -inline \
				{inet \d+.\d+.\d+.\d+|inet6 [\w%:]+} \
				$ip_address_output
		] {

			if {[lindex $match 0] eq "inet"} {

				# In the ifconfig output, the inet addresses come before the
				# inet6 addresses, so as we loop through all the address lines
				# from the ifconfig output, append the inet addresses to the
				# list with an initial rank of 0
				set inet6_count 0
				lappend ranked_ip_addresses [
					list [lindex $match end] $inet6_count
				]

			} else {

				# As we find inet6 addresses, increment their count and update
				# the rank value of the associated inet address.
				incr inet6_count
				lset ranked_ip_addresses end end $inet6_count
			}
		}

		# Strip out the localhost address. We do not want it in our list yet.
		set ranked_ip_addresses [
			lsearch -all -inline -not -exact -index 0 $ranked_ip_addresses \
				127.0.0.1
		]

		# Sort the list of ranked IPv4 addresses by rank from highest to lowest.
		# Then strip out the ranks leaving a list of IPv4 addresses.
		set system_info::ip_addresses [
			lmap ranked_ip [
				lsort -integer -decreasing -index 1 $ranked_ip_addresses
			]  {
				lindex $ranked_ip 0
			}
		]

		# Clean up all temporary variables
		unset ranked_ip_addresses
		unset inet6_count
	}
}

# From the list of ip addresses, create a list of broadcast addresses by
# replacing the final octet of each with 255
set system_info::broadcast_addresses [
	lmap ip_address $system_info::ip_addresses {
		join [lreplace [split $ip_address .] end end 255] .
	}
]

# Tack on the localhost address to the list of ip addresses. In the worst case,
# this will be our only address to choose from.
lappend system_info::ip_addresses 127.0.0.1
