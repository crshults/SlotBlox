package require TclOO

oo::class create change_tracked_variable {
    variable _variable _callback

    constructor {initial_value callback} {
        set _variable $initial_value
        set _callback $callback
        $_callback
    }

    method set {new_value} {
        if {$new_value != $_variable} {
            set _variable $new_value
            $_callback
        }
    }

    method get {} {
        return $_variable
    }
}

# Example usage
# package require change_tracked_variable
# proc status_changed {} {puts "status changed to [status get]"}
# change_tracked_variable create status Unknown status_changed
# status set Idle
# status set Idle
# status set Running
