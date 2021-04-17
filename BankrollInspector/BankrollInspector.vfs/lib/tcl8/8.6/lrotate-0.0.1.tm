proc lrotate {the_list} {
    upvar 1 $the_list local_list
    set local_list [join [list [lrange $local_list 1 end] [lindex $local_list 0]]]
}
