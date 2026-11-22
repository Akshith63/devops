
#!/bin/bash

# Q34: AWS Unattached EBS Volume Audit

# Configure AWS regions
REGIONS=("ap-south-1" "us-east-1")

# Configuration files
RATE_FILE="ebs_rates.csv"
REPORT_FILE="unattached_ebs_report.csv"
ERROR_LOG="ebs_audit_errors.log"

echo "======================================"
echo "      AWS UNATTACHED EBS AUDIT"
echo "======================================"

# Check required commands
for CMD in aws jq awk; do
    if ! command -v "$CMD" >/dev/null 2>&1; then
        echo "ERROR: Required command $CMD is missing."
        exit 1
    fi
done

# Check pricing file
if [ ! -f "$RATE_FILE" ]; then
    echo "ERROR: Pricing file $RATE_FILE not found."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "ERROR: AWS credentials are not configured."
    exit 1
fi

# CSV report header
echo "region,volume_id,volume_name,size_gb,volume_type,creation_date,rate_usd_per_gb_month,estimated_monthly_cost_usd" > "$REPORT_FILE"

TOTAL_VOLUMES=0
TOTAL_SIZE=0
TOTAL_COST=0
FAILED_REGIONS=0
MISSING_RATES=0

# Process each AWS region
for REGION in "${REGIONS[@]}"
do
    echo ""
    echo "Checking region: $REGION"

    # Retrieve unattached EBS volumes
    if VOLUMES=$(aws ec2 describe-volumes \
        --region "$REGION" \
        --filters Name=status,Values=available \
        --output json 2>>"$ERROR_LOG"); then

        REGION_COUNT=$(printf '%s\n' "$VOLUMES" |
            jq '[.Volumes[]?] | length')

        echo "Unattached volumes found: $REGION_COUNT"

        # Extract volume details
        while IFS=$'\t' read -r VOL_ID NAME SIZE TYPE CREATED
        do
            [ -z "$VOL_ID" ] && continue

            TOTAL_VOLUMES=$((TOTAL_VOLUMES + 1))
            TOTAL_SIZE=$((TOTAL_SIZE + SIZE))

            # Find the configured regional storage rate
            RATE=$(awk -F',' -v region="$REGION" -v type="$TYPE" '
                NR > 1 &&
                $1 == region &&
                $2 == type {
                    print $3
                    exit
                }
            ' "$RATE_FILE")

            if [ -z "$RATE" ]; then
                COST=""
                RATE="NOT_CONFIGURED"
                MISSING_RATES=$((MISSING_RATES + 1))

                echo "WARNING: No price configured for $REGION / $TYPE"
            else
                # Calculate estimated monthly storage cost
                COST=$(awk -v size="$SIZE" -v rate="$RATE" \
                    'BEGIN { printf "%.2f", size * rate }')

                TOTAL_COST=$(awk -v total="$TOTAL_COST" -v cost="$COST" \
                    'BEGIN { printf "%.2f", total + cost }')
            fi

            # Write correctly escaped CSV record
            jq -nr \
                --arg region "$REGION" \
                --arg id "$VOL_ID" \
                --arg name "$NAME" \
                --arg size "$SIZE" \
                --arg type "$TYPE" \
                --arg created "$CREATED" \
                --arg rate "$RATE" \
                --arg cost "$COST" \
                '[$region,$id,$name,$size,$type,$created,$rate,$cost] | @csv' \
                >> "$REPORT_FILE"

            echo "Volume: $VOL_ID | Type: $TYPE | Size: ${SIZE}GB | Cost: ${COST:-N/A}"

        done < <(
            printf '%s\n' "$VOLUMES" | jq -r '
                .Volumes[]? |
                [
                    .VolumeId,
                    ([.Tags[]? | select(.Key == "Name") | .Value][0] // "Unnamed"),
                    (.Size | tostring),
                    .VolumeType,
                    .CreateTime
                ] | @tsv
            '
        )

    else
        echo "ERROR: Unable to retrieve volumes from $REGION"
        echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: AWS request failed for $REGION" >> "$ERROR_LOG"
        FAILED_REGIONS=$((FAILED_REGIONS + 1))
    fi

done

# Final summary
echo ""
echo "======================================"
echo "          AUDIT SUMMARY"
echo "======================================"
echo "Regions checked: ${#REGIONS[@]}"
echo "Failed regions: $FAILED_REGIONS"
echo "Unattached volumes: $TOTAL_VOLUMES"
echo "Total provisioned storage: ${TOTAL_SIZE} GB"
echo "Estimated monthly storage cost: \$${TOTAL_COST}"
echo "Volumes without configured rates: $MISSING_RATES"
echo "CSV report: $REPORT_FILE"
echo "Error log: $ERROR_LOG"
echo "======================================"

if [ "$FAILED_REGIONS" -gt 0 ] || [ "$MISSING_RATES" -gt 0 ]; then
    exit 1
fi

exit 0

