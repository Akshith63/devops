
#!/bin/bash

# Q6: Disk Usage Monitoring

echo "----- Disk Usage Report -----"

found=0

df -P -h | awk 'NR > 1 {
    usage = $5
    gsub("%", "", usage)

    if (usage > 80) {
        printf "WARNING: Mount Point: %s | Usage: %s%%\n", $6, usage
        found = 1
    }
}

END {
    if (found == 0) {
        print "NORMAL: All monitored filesystems are below or equal to 80%."
    }
}'

