#!/usr/bin/expect -f

set password [lindex $argv 0]
set files [lrange $argv 1 1]
spawn rpm --addsign $files
expect "Enter pass phrase:"
send -- "$password\r"
expect eof

