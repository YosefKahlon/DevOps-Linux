FROM alpine:latest

# Install curl for sending notifications, jq for parsing JSON, and docker-cli for 'docker events'
RUN apk add --no-cache curl jq docker-cli

# Copy the notification script into the container
COPY notify.sh /usr/local/bin/notify.sh

# Make the script executable
RUN chmod +x /usr/local/bin/notify.sh

# Set the command to run the script
CMD ["notify.sh"]
