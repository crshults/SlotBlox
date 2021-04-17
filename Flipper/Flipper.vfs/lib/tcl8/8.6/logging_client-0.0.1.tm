package require client

client create logging_client logging_server callback
proc callback {message} {}

proc log {name message} {
	catch {logging_client send "[clock microseconds] $name $message"}
}
