
#!/bin/bash

# Q7: Process Status Checker

echo "Enter process name:"
read -r process

pids=$(pgrep -x "$process")

if [ -n "$pids" ]
then
    echo "PROCESS IS RUNNING"
    echo "Process ID(s):"
    echo "$pids"
else
    echo "PROCESS NOT RUNNING"
fi

