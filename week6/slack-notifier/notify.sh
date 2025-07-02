#!/bin/sh

# SLACK_WEBHOOK_URL is expected to be set as an environment variable

if [ -z "$SLACK_WEBHOOK_URL" ]; then
  echo "Error: SLACK_WEBHOOK_URL environment variable is not set."
  exit 1
fi

echo "Slack Notifier started. Monitoring Docker events..."

# Listen to Docker events. We are interested in container and health_status events.
# Filters: type=container, and specific events like start, stop, die, health_status
docker events --filter 'type=container' --filter 'event=start' --filter 'event=stop' --filter 'event=die' --filter 'event=health_status' --format '{{json .}}' | while read -r event_json
do
  # Ensure event_json is not empty
  if [ -z "$event_json" ]; then
    continue
  fi

  event_type=$(echo "$event_json" | jq -r '.Type')
  action=$(echo "$event_json" | jq -r '.Action')
  container_id=$(echo "$event_json" | jq -r '.Actor.ID')
  container_name=$(echo "$event_json" | jq -r '.Actor.Attributes.name')
  image_name=$(echo "$event_json" | jq -r '.Actor.Attributes.image')

  # Construct message based on event action
  message=""
  if echo "$action" | grep -q "health_status:"; then
    health_status_val=$(echo "$action" | cut -d' ' -f2) # Extracts 'healthy' or 'unhealthy'
    message="🏥 Docker Health: Container \`$container_name\` (ID: \`${container_id:0:12}\`, Image: \`$image_name\`) is now \`$health_status_val\`."
  elif [ "$action" = "die" ]; then
    exit_code=$(echo "$event_json" | jq -r '.Actor.Attributes.exitCode')
    message="💀 Docker Alert: Container \`$container_name\` (ID: \`${container_id:0:12}\`, Image: \`$image_name\`) has died with exit code \`$exit_code\`."
  elif [ "$action" = "stop" ]; then
    message="🛑 Docker Info: Container \`$container_name\` (ID: \`${container_id:0:12}\`, Image: \`$image_name\`) has stopped."
  elif [ "$action" = "start" ]; then
    message="🚀 Docker Info: Container \`$container_name\` (ID: \`${container_id:0:12}\`, Image: \`$image_name\`) has started."
  else
    # Skip other events not explicitly handled
    echo "Skipping event: $action for $container_name"
    continue
  fi

  if [ -n "$message" ]; then
    echo "Preparing to send to Slack: $message"
    # Construct JSON payload for Slack
    json_payload=$(jq -n --arg text "$message" '{text: $text}')

    # Send to Slack
    # Adding -m 60 to set a maximum time for the curl operation to 60 seconds
    # Adding --retry 3 and --retry-delay 5 for resilience
    curl_response=$(curl -s -X POST -H 'Content-type: application/json' --data "$json_payload" "$SLACK_WEBHOOK_URL" -m 60 --retry 3 --retry-delay 5)
    
    # Check if curl command itself failed (e.g., network issue before HTTP response)
    if [ $? -ne 0 ]; then
        echo "Error: curl command failed to execute."
    # Check if Slack API returned "ok"
    elif echo "$curl_response" | grep -q "ok"; then
      echo "Successfully sent notification to Slack."
    else
      echo "Error sending notification to Slack. Response: $curl_response"
    fi
  fi
done
