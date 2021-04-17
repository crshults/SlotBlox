proc lremove {the_list what_to_remove} {
    upvar 1 $the_list local_list
    set local_list [lsearch -inline -all -not -exact $local_list $what_to_remove]
}
