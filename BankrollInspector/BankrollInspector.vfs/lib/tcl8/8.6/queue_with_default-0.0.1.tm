package require TclOO

oo::class create queue_with_default {
    variable _queue _default _default_in_queue _default_seen
    
    constructor {default} {
        set _queue [list]
        set _default $default
        my pop
    }
    
    method push {message} {
        lappend _queue $message
        if {$_default_in_queue && !$_default_seen} {
            my pop
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
            my push $_default
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