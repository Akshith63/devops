
#!/bin/bash

# Q33: AWS EC2 Inventory Automation

# Configure AWS regions
REGIONS=("ap-south-1" "us-east-1" "ap-southeast-1")

# Output files
REPORT_FILE="ec2_inventory_report.csv"
ERROR_LOG="ec2_inventory_errors.log"

echo "======================================"
echo "       AWS EC2 INVENTORY"
echo "======================================"

# Check required commands
for CMD in aws jq; do
    if ! command -v "$CMD" >/dev/null 2>&1; then
        echo "ERROR: $CMD is not installed."
        exit 1
    fi
done

# Check AWS credentials and identity
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "ERROR: AWS credentials or access are not configured."
    exit 1
fi

# Create CSV report
echo "region,instance_id,instance_name,instance_type,state,availability_zone,tags" > "$REPORT_FILE"

TOTAL=0
SUCCESS=0
FAILED=0

# Process each configured region
for REGION in "${REGIONS[@]}"
do
    echo ""
    echo "Checking AWS region: $REGION"

    # Retrieve EC2 instances
    if INSTANCES_JSON=$(aws ec2 describe-instances \
        --region "$REGION" \
        --output json 2>>"$ERROR_LOG"); then

        # Convert JSON instance information into CSV
        if printf '%s\n' "$INSTANCES_JSON" | jq -r --arg region "$REGION" '
            .Reservations[]?.Instances[]? |
            [
                $region,
                .InstanceId,
                ([.Tags[]? | select(.Key == "Name") | .Value][0] // "Unnamed"),
                .InstanceType,
                .State.Name,
                .Placement.AvailabilityZone,
                ([.Tags[]? | "\(.Key)=\(.Value)"] | join("; "))
            ] | @csv
        ' >> "$REPORT_FILE"; then

            REGION_COUNT=$(printf '%s\n' "$INSTANCES_JSON" |
                jq '[.Reservations[]?.Instances[]?] | length')

            TOTAL=$((TOTAL + REGION_COUNT))
            SUCCESS=$((SUCCESS + 1))

            echo "Successfully checked: $REGION"
            echo "Instances found: $REGION_COUNT"

        else
            echo "ERROR: Unable to process instance data for $REGION"
            echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: JSON processing failed for $REGION" >> "$ERROR_LOG"
            FAILED=$((FAILED + 1))
        fi

    else
        echo "ERROR: Unable to retrieve EC2 instances from $REGION"
        echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: AWS request failed for $REGION" >> "$ERROR_LOG"
        FAILED=$((FAILED + 1))
    fi

done

# Display summary
echo ""
echo "======================================"
echo "          INVENTORY SUMMARY"
echo "======================================"
echo "Regions checked: ${#REGIONS[@]}"
echo "Successful regions: $SUCCESS"
echo "Failed regions: $FAILED"
echo "Total EC2 instances: $TOTAL"
echo "CSV report: $REPORT_FILE"
echo "Error log: $ERROR_LOG"
echo "======================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi

exit 0

