proc convert_binary_to_bit_list {input} {
    binary scan $input B* bit_string
    split $bit_string ""
}

proc invert_bit_list {bit_list} {
    foreach bit $bit_list {
        switch $bit {
            0 {lappend inverted_bit_list 1}
            1 {lappend inverted_bit_list 0}
        }
    }
    return $inverted_bit_list
}

package require list_tools

proc bassign {input fields_and_lengths} {
    set bit_list [convert_binary_to_bit_list $input]
    foreach {field length} $fields_and_lengths {
        uplevel "scan [join [lpop bit_list $length] ""] %b $field"
    }
    return [binary format B* [join $bit_list ""]]
}
