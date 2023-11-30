#!/bin/bash

# Script to list and optionally delete S3 objects older than one year

BUCKET_NAME="reytsiacstate"  # Replace with your bucket name

# Get current date in seconds since the epoch
current_date=$(date +%s)
# Calculate the cutoff date (current date - 1 year)
cutoff_date=$(date -v-1y +%s)

# Function to convert a date to seconds since the epoch
date_to_seconds() {
    local stripped_date=${1%+*}
    local formatted_date="${stripped_date%:*}Z"  # Remove seconds and timezone offset
    echo "Processing date: $formatted_date"  # Debug output
    date -j -u -f "%Y-%m-%dT%H:%M:00Z" "$formatted_date" +%s 2>/dev/null
}
echo $date_to_seconds
# last_modified="Last Modified: 2022-07-27T13:17:37+00"
# processing_date="Processing date: 2022-07-27T13:17Z"

# Function to convert date to a common format
# convert_date() {
#     local input_date="$1"
#     # Extract the date part (assuming the format is consistent)
#     local date_part=$(echo "$input_date" | sed -E 's/.*([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}).*/\1/')
#     # Normalize and print the date in the desired format
#     date -j -u -f "%Y-%m-%dT%H:%M" "$date_part" +%Y-%m-%dT%H:%M:%SZ
# }

# Convert and print the dates
# echo "Normalized Last Modified: $(convert_date "$last_modified")"
# echo "Normalized Processing Date: $(convert_date "$processing_date")"
# List all objects and their last modified dates
echo "Querying S3 for objects..."
objects=$(aws s3api list-objects --bucket "$BUCKET_NAME" --query 'Contents[].{Key: Key, LastModified: LastModified}' --output text)

# Debug output to inspect the AWS CLI command results
echo "AWS CLI Output:"
echo "$objects"
echo "End of AWS CLI Output"

# Check each object
echo "Objects older than one year:"
while read -r key last_modified; do
    # Skip empty lines
    [[ -z "$key" ]] && continue

    # Convert last modified date to seconds since the epoch
    lm_seconds=$(date_to_seconds "$last_modified")
    echo "Read key: $key, Last Modified: ${last_modified%:*}"  # Debug output without seconds
    echo $lm_seconds
    # Compare last modified date to cutoff date
    if [[ $lm_seconds -le $cutoff_date ]]; then
        echo "Object to delete: $key"
        # Ask for confirmation before deletion
        read -p "Do you want to delete '$key'? (yes/no) " -r
        if [[ $REPLY =~ ^yes$ ]]; then
            aws s3 rm "s3://${BUCKET_NAME}/${key}"
            echo "Deleted $key"
        else
            echo "Skipped $key"
        fi
    fi
done <<< "$objects"

echo "Operation complete."



resource "aws_iam_role" "stepfunctions_role" {
  name = "stepfunctions_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "stepfunctions_policy" {
  name        = "stepfunctions_policy"
  description = "A policy for Step Functions to access AWS services"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
          "logs:*",
          // Add other actions as needed
        ],
        Resource = "*",
        Effect   = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "stepfunctions_policy_attachment" {
  role       = aws_iam_role.stepfunctions_role.name
  policy_arn = aws_iam_policy.stepfunctions_policy.arn
}

