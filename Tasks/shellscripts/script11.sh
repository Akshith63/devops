
#!/bin/bash

# Iterate through numbers 1 to 30
for num in {1..30}
do
    # Stop execution when number reaches 25
    if [ "$num" -eq 25 ]; then
        break
    fi

    # Skip numbers divisible by 3
    if [ $((num % 3)) -eq 0 ]; then
        continue
    fi

    echo "$num"
done

