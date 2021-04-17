package require TclOO

oo::class create poller {
    variable _period _timeout_period _request_action _response_action _timeout_action
    variable _scheduled_poller_action _scheduled_poller_timeout

    constructor {period timeout_period request_action response_action timeout_action} {
        set _period          $period
        set _timeout_period  $timeout_period
        set _request_action  $request_action
        set _response_action $response_action
        set _timeout_action  $timeout_action
        return
    }

    destructor {
        my stop
    }

    method start {} {
        set _scheduled_poller_action [after 0 [list [self] send_request]]
        set _scheduled_poller_timeout [after $_timeout_period [list [self] timeout]]
        return
    }

    method stop {} {
        after cancel $_scheduled_poller_action
        after cancel $_scheduled_poller_timeout
        return
    }

    method postpone_timeout {} {
        after cancel $_scheduled_poller_timeout
        set _scheduled_poller_timeout [after $_timeout_period [list [self] timeout]]
        return
    }

    method send_request {} {
        $_request_action
        set _scheduled_poller_action [after $_period [list [self] read_response]]
    }

    method read_response {} {
        $_response_action
        set _scheduled_poller_action [after 0 [list [self] send_request]]
    }

    method timeout {} {
        my stop
        $_timeout_action
    }
}
