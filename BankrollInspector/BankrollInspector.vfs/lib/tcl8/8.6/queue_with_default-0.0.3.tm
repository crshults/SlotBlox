package require TclOO

oo::class create queue_with_default {
    variable _queue _default _default_in_queue _default_seen
    
    constructor {default} {
        set _queue [list]
        set _default $default
        my pop
    }

    method set_default {default} {
        set _default $default
        if {$_default_in_queue} {
            set _queue [lreplace $_queue 0 0 $_default]
        }
        return
    }

    method push_back {message} {
        lappend _queue $message
        if {$_default_in_queue && !$_default_seen} {
            my pop
        }
        return
    }

    method push_front {message} {
        if {$_default_in_queue && $_default_seen} {
            set _queue [linsert $_queue 1 $message]
        } else {
            set _queue [linsert $_queue 0 $message]
        }
        return
    }

    method peek {} {
        if {$_default_in_queue} {
            set _default_seen yes
        }
        lindex $_queue 0
    }

    method pop {} {
        set _queue [lrange $_queue 1 end]
        set _default_in_queue no
        set _default_seen no
        if {[llength $_queue] == 0} {
            my push_back $_default
            set _default_in_queue yes
            set _default_seen no
        }
        return
    }

    method clear {} {
        set _queue [list]
        my pop
    }
}
