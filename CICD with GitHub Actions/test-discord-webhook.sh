#!/bin/bash

# Discord Webhook Test Script
# This script helps test your Discord webhook integration

echo "🔔 Discord Webhook Test Script"
echo "=============================="

# Check if webhook URL is provided
if [ -z "$1" ]; then
    echo "❌ Usage: $0 <DISCORD_WEBHOOK_URL>"
    echo "   Example: $0 https://discord.com/api/webhooks/123456789/abcdef..."
    exit 1
fi

WEBHOOK_URL="$1"

echo "🚀 Testing Discord webhook..."

# Test 1: Simple message
echo "📝 Sending simple test message..."
curl -H "Content-Type: application/json" \
     -X POST \
     -d '{"content": "🧪 **Webhook Test**: Simple message from CI/CD test script"}' \
     "$WEBHOOK_URL"

echo -e "\n\n"

# Test 2: Rich embed (similar to CI notifications)
echo "📝 Sending rich embed test message..."
curl -H "Content-Type: application/json" \
     -X POST \
     -d '{
       "embeds": [{
         "title": "🧪 Test Notification",
         "description": "This is a test of the Discord webhook integration for CI/CD notifications",
         "color": 3066993,
         "fields": [
           {
             "name": "Test Type",
             "value": "Manual webhook test",
             "inline": true
           },
           {
             "name": "Status",
             "value": "Success ✅",
             "inline": true
           },
           {
             "name": "Repository",
             "value": "DevOps-Linux/week5",
             "inline": true
           },
           {
             "name": "Branch",
             "value": "main",
             "inline": true
           },
           {
             "name": "Node.js Version",
             "value": "18",
             "inline": true
           },
           {
             "name": "Test Details",
             "value": "If you see this message, your Discord webhook is working correctly!",
             "inline": false
           }
         ],
         "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
         "footer": {
           "text": "Webhook Test Script"
         }
       }]
     }' \
     "$WEBHOOK_URL"

echo -e "\n\n"

# Test 3: Failure notification simulation
echo "📝 Sending failure notification test..."
curl -H "Content-Type: application/json" \
     -X POST \
     -d '{
       "embeds": [{
         "title": "❌ Test Failure Notification",
         "description": "This simulates what a CI/CD failure notification would look like",
         "color": 15158332,
         "fields": [
           {
             "name": "Job",
             "value": "test-webhook-integration",
             "inline": true
           },
           {
             "name": "Status",
             "value": "Simulated Failure",
             "inline": true
           },
           {
             "name": "Node.js Version",
             "value": "16",
             "inline": true
           },
           {
             "name": "Error Type",
             "value": "Test simulation only",
             "inline": true
           },
           {
             "name": "View Logs",
             "value": "[Click here](https://github.com/your-repo/actions)",
             "inline": false
           }
         ],
         "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
         "footer": {
           "text": "GitHub Actions (Test)"
         }
       }]
     }' \
     "$WEBHOOK_URL"

echo -e "\n\n✅ Webhook test complete!"
echo "Check your Discord channel for the test messages."
echo ""
echo "If you see all three messages, your webhook is ready for CI/CD integration!"
echo ""
echo "🔧 Next steps:"
echo "1. Add the webhook URL to your GitHub repository secrets as 'DISCORD_WEBHOOK_URL'"
echo "2. Push a commit to trigger the CI/CD pipeline"
echo "3. Watch for real notifications in your Discord channel"
