# Discord Webhook Setup for CI/CD Notifications

This guide explains how to set up Discord webhook notifications for your GitHub Actions CI/CD pipeline.

## 🔧 Setting Up Discord Webhook

### Step 1: Create a Discord Webhook

1. Open Discord and navigate to your server
2. Right-click on the channel where you want notifications
3. Select **Edit Channel** → **Integrations** → **Webhooks**
4. Click **Create Webhook**
5. Give it a name like "CI/CD Notifications"
6. Copy the webhook URL

### Step 2: Add Webhook to GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `DISCORD_WEBHOOK_URL`
5. Value: Paste your Discord webhook URL
6. Click **Add secret**

## 📋 Notification Features

The enhanced CI/CD pipeline now includes:

### 🎯 Individual Job Notifications
- **Success notifications** for each job completion (backend/frontend)
- **Failure notifications** with direct links to logs
- **Matrix strategy support** - separate notifications for each Node.js version

### 📊 Rich Embed Information
Each notification includes:
- Job name and status
- Node.js version being tested
- Repository and branch information
- Commit hash with clickable link
- Timestamp
- Direct links to workflow logs (for failures)

### 🏆 Deployment Summary
- Final summary notification after all jobs complete
- Overall status (success/failure)
- Individual job status breakdown
- Links to full workflow run

## 🎨 Notification Types

### ✅ Success Notifications
- **Green color** (3066993)
- Checkmark emoji
- Job completion timestamp
- All relevant metadata

### ❌ Failure Notifications
- **Red color** (15158332)
- X emoji
- Direct link to workflow logs
- Debugging information

### 📈 Summary Notifications
- **Color based on overall status**
- Complete pipeline overview
- Individual job results
- Workflow run links

## 🔄 Workflow Structure

```
CI Pipeline
├── backend-tests (Node.js 16, 18)
│   ├── Run tests
│   ├── Upload artifacts
│   ├── Validate deployment
│   └── Send Discord notification
├── frontend-tests (Node.js 16, 18)
│   ├── Run tests
│   ├── Upload artifacts
│   ├── Validate deployment
│   └── Send Discord notification
└── deployment-summary
    └── Send overall status to Discord
```

## 🧪 Testing the Setup

1. **Push a commit** to trigger the workflow
2. **Check Discord** for notifications
3. **Verify all matrix jobs** send individual notifications
4. **Confirm summary** notification appears after all jobs complete

## 🛠️ Customization Options

### Modify Notification Content
Edit the JSON payload in the workflow file to customize:
- Embed titles and descriptions
- Colors and emojis
- Field information
- Links and formatting

### Add More Notification Triggers
You can add notifications for:
- Deployment starts
- Specific test failures
- Performance metrics
- Security scan results

### Channel Routing
Create multiple webhooks for different channels:
- Success notifications → #ci-success
- Failure notifications → #ci-alerts
- Summary notifications → #deployments

## 🔍 Troubleshooting

### Common Issues

1. **Webhook URL not working**
   - Verify the URL is correct in GitHub secrets
   - Check Discord webhook is still active

2. **Notifications not appearing**
   - Check workflow logs for curl errors
   - Verify JSON syntax in webhook payload

3. **Missing information in notifications**
   - Ensure all GitHub context variables are available
   - Check matrix strategy is properly configured

### Debug Commands

Test webhook manually:
```bash
curl -H "Content-Type: application/json" \
     -X POST \
     -d '{"content": "Test notification"}' \
     YOUR_WEBHOOK_URL
```

## 📝 Example Notification

Here's what a successful backend test notification looks like:

```
✅ Backend Tests Passed
Backend tests for Node.js 18 completed successfully

Job: backend-tests
Node.js Version: 18
Repository: username/repo-name
Branch: main
Commit: abc123def (linked)
Duration: Job completed at 2024-01-15T10:30:00Z

GitHub Actions
```

## 🚀 Next Steps

With Discord notifications set up, you now have:
- Real-time CI/CD status updates
- Quick access to failure logs
- Complete pipeline visibility
- Team collaboration improvements

The pipeline will automatically notify your Discord channel for every push, pull request, or manual workflow trigger!
