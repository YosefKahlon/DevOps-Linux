# CI/CD with GitHub Actions

## Questions and Answers

### What is a GitHub Action?

A **GitHub Action** is a custom application that performs a frequently repeated task in your software development workflow. GitHub Actions are the individual units of functionality that can be combined to create workflows. They can be:

- **Pre-built actions** from the GitHub Marketplace (created by GitHub or the community)
- **Custom actions** that you create yourself
- **Docker container actions** or **JavaScript actions**

Actions can perform tasks like:
- Building and testing code
- Deploying applications
- Sending notifications
- Interacting with APIs
- Managing issues and pull requests

**Where do GitHub Actions run?**
GitHub Actions run on **GitHub-hosted runners** (virtual machines in the cloud), not on your local machine. GitHub provides runners with different operating systems:
- **Ubuntu Linux** (most common)
- **Windows Server**
- **macOS**

You can also use **self-hosted runners** if you need to run actions on your own infrastructure for security, performance, or specific environment requirements.

### What is the difference between a job and a step?

**Job:**
- A **job** is a set of steps that execute on the same runner (virtual machine)
- Jobs run in parallel by default (unless dependencies are specified)
- Each job runs in a fresh virtual environment
- Jobs can have dependencies on other jobs using the `needs` keyword
- Example: You might have separate jobs for "build", "test", and "deploy"

**Step:**
- A **step** is an individual task within a job
- Steps run sequentially within a job
- Each step can run commands or use actions
- Steps share the same runner environment and file system
- Steps can pass data between each other within the same job

**Hierarchy:**
```
Workflow
├── Job 1
│   ├── Step 1
│   ├── Step 2
│   └── Step 3
└── Job 2
    ├── Step 1
    └── Step 2
```

### What triggers a workflow?

GitHub workflows can be triggered by various **events**:

**1. Push Events:**
- `push` - When code is pushed to specific branches
- `pull_request` - When a pull request is opened, updated, or closed

**2. Scheduled Events:**
- `schedule` - Run workflows on a schedule using cron syntax
- Example: `cron: '0 0 * * *'` (daily at midnight)

**3. Manual Events:**
- `workflow_dispatch` - Manually trigger workflows from GitHub UI
- `repository_dispatch` - Trigger via API calls

**4. Repository Events:**
- `issues` - When issues are created, edited, etc.
- `release` - When releases are published
- `fork` - When the repository is forked

**5. External Events:**
- `webhook` - External webhooks
- API calls to trigger workflows

**Example trigger configuration:**
```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'  # Every Monday at 2 AM
  workflow_dispatch:  # Manual trigger
```