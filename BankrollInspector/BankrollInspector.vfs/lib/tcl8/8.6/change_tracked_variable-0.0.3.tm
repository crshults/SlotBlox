package require TclOO

oo::class create change_tracked_variable {
    variable _variable _default _callback

    constructor {initial_value callback} {
        set _variable $initial_value
        set _default  $initial_value
        set _callback $callback
        $_callback
    }

    method set {new_value {custom_callback {}}} {
        if {$new_value != $_variable} {
            set _variable $new_value
            $_callback
            eval $custom_callback
        }
    }

    method get {} {
        return $_variable
    }

    method reset {} {
        my set $_default
    }
}

# Example usage
# package require change_tracked_variable
# proc status_changed {} {puts "status changed to [status get]"}
# change_tracked_variable create status Unknown status_changed
# status set Idle
# status set Idle
# status set Running
