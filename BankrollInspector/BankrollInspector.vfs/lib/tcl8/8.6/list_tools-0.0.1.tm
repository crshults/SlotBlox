proc lremove {the_list args} {
    upvar 1 $the_list local_list
    foreach what_to_remove $args {
        set local_list [lsearch -inline -all -not -exact $local_list $what_to_remove]
    }
}

proc lrotate {the_list} {
    upvar 1 $the_list local_list
    set local_list [join [list [lrange $local_list 1 end] [lindex $local_list 0]]]
}

proc lpop {the_list {number_to_pop 1}} {
    upvar 1 $the_list local_list
    set pop_list [lrange $local_list 0 $number_to_pop-1]
    set local_list [lrange $local_list $number_to_pop end]
    return $pop_list
}
