# Create and Run Multi-Container App with Docker Compose

When we have a basic multi-service architecture (e.g., backend + database).we like to use docker compse file for run Multi-Container App.


In this example we **Defined a `docker-compose.yml` file** with a basic multi-service architecture:
   - Two main services: `backend` (Node.js app) and `db` (PostgreSQL database).
   - We configured the backend to connect to the database using the service name `db` as the hostname.
   -And we added an explicit custom network (`app-network`) to ensure clear and reliable communication between services.

2. **Started the application with Docker Compose:**
   - To build and start both containers.
   ```bash
   docker-compose up --build
   ```
   - To verify that both the backend and db containers are running and mapped to the correct ports.
   ```bash
    docker-compose ps
   ```

3. **Inspected networking between containers:**
   - Verified that the backend can communicate with the db service using the command:
     ```bash
     docker-compose exec backend ping db
     ```
   - The successful ping confirmed that the containers are on the same network and can resolve each other by service name.

# Volume Mounting and Persistent Data



1. **Added a named volume for persistent database data:**
   - The `db` (PostgreSQL) service uses a named volume (`db_data`) to store its data at `/var/lib/postgresql/data`.
   - This ensures that database data is not lost when containers are stopped or removed.

2. **Mounted a local configuration file into the backend container:**
   - Created a `.env` file in the `backend` directory for environment variables.
   - Updated the `docker-compose.yml` to mount this local `.env` file into the backend container at `/app/.env` using the `volumes` key:
     ```yaml
     volumes:
       - ./backend/.env:/app/.env
     ```
   - **What does this mean?**
     - "Mounting a local configuration file" means making a file from your host machine (like `.env`) available inside the running container at a specific path.
     - This allows the containerized application to read configuration (such as environment variables, API URLs, secrets, etc.) from a file that you control and can easily edit on your host.
     - It is useful for keeping sensitive or environment-specific settings outside of your codebase and Docker image.

3. **Restarted the app to verify persistence:**
   - After restarting the containers, any data stored in the database remains available, confirming that the named volume works as intended.

# Healthchecks and Logging

1. **Added a healthcheck to the backend service:**
   - Updated the `docker-compose.yml` to include a `healthcheck` for the backend service. This healthcheck uses `curl` to check the `/health` endpoint of the backend every 30 seconds, with a 10-second timeout and up to 3 retries.
   - Example configuration:
     ```yaml
     healthcheck:
       test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
       interval: 30s
       timeout: 10s
       retries: 3
       start_period: 10s
     ```

2. **Log healthcheck failures and simulate recovery:**
   - If the healthcheck fails, Docker will mark the container as `unhealthy`. You can view these events in the logs.
  

3. **Verified logs and container behavior:**
   To view log output and confirm healthcheck status and failures.
   
   ```bash 
   docker-compose logs backend
   ```

 # Azure VM Setup and Manual Deployment

1. **Created an Azure Virtual Machine (VM):**
   - Used the Azure Portal or Azure CLI to create a Linux VM (Ubuntu) with a public IP and an admin username (`azureuser`).
   - Downloaded the private SSH key (`myDockerVM_key.pem`) for secure access.
   - Store the key in ~/.ssh/ folder.

2. **Configured SSH Access:**
   - Set permissions on the key file using `chmod 600 ~/.ssh/myDockerVM_key.pem`.
   - Connected to the VM using:
     ```bash
     ssh -i ~/.ssh/myDockerVM_key.pem azureuser@<vm-public-ip>
     ```

3. **Installed Docker and Docker Compose on the VM:**
   - Updated the package list and installed Docker:
     ```bash
     sudo apt-get update
     sudo apt-get install -y docker.io
     sudo systemctl enable --now docker
     sudo usermod -aG docker $USER
     ```
   - Installed Docker Compose:
     ```bash
     sudo apt-get install -y docker-compose
     ```
   - Logged out and back in (or used `newgrp docker`) to apply Docker group permissions.

4. **Deployed the Application:**
   - Copied the application files (excluding the `frontend` folder) from the local machine to the VM using `rsync`:
     ```bash
     rsync -av --exclude=frontend -e "ssh -i ~/.ssh/myDockerVM_key.pem" /home/yosef/Documents/github/DevOps-Linux/DevOps-Linux/week7/ azureuser@<vm-public-ip>:~/week7/
     ```
   - Navigated to the app directory on the VM:
     ```bash
     cd ~/week7
     ```

5. **Started the Application with Docker Compose:**
   - Built and started the containers:
     ```bash
     docker-compose up --build -d
     ```
   - Verified that the containers are running:
     ```bash
     docker-compose ps
     ```

6. **Exposed the Application on a Public Port:**
   - Ensured port 3000 was open in Azure Network Security Group settings.
   - Accessed the running application from a browser or with `curl`:
     ```
     http://<vm-public-ip>:3000
     ```

7. **Tested the API:**
   - Used `curl` to test the health endpoint and add users:
     ```bash
     curl http://localhost:3000/health
     curl -X POST http://localhost:3000/api/users -H "Content-Type: application/json" -d '{"name": "Alice", "email": "alice@example.com"}'
     ```

**Result:**  
The application is now running on the Azure VM, accessible from the public IP on port 3000, and can be managed using Docker Compose.


# Deploy to Azure VM via CI/CD

Instead of deploying manually, we automated the deployment process using GitHub Actions. This allows us to build, test, and deploy our application to the Azure VM automatically whenever changes are pushed to the repository.


**Key parts of the deploy job:**

```yaml
deploy:
  needs: e2e
  runs-on: ubuntu-latest

  steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up SSH key
      run: |
        mkdir -p ~/.ssh
        echo "${{ secrets.AZURE_VM_KEY }}" > ~/.ssh/myDockerVM_key.pem
        chmod 600 ~/.ssh/myDockerVM_key.pem

    - name: Copy files to Azure VM (excluding frontend)
      run: |
        rsync -av --exclude=frontend -e "ssh -i ~/.ssh/myDockerVM_key.pem -o StrictHostKeyChecking=no" week7/ ${{ secrets.AZURE_VM_USER }}@${{ secrets.AZURE_VM_HOST }}:~/week7/

    - name: Deploy with Docker Compose on Azure VM
      run: |
        ssh -i ~/.ssh/myDockerVM_key.pem -o StrictHostKeyChecking=no ${{ secrets.AZURE_VM_USER }}@${{ secrets.AZURE_VM_HOST }} '
          cd ~/week7 && docker-compose up --build -d
        '

    - name: Check service health on Azure VM
      run: |
        ssh -i ~/.ssh/myDockerVM_key.pem -o StrictHostKeyChecking=no ${{ secrets.AZURE_VM_USER }}@${{ secrets.AZURE_VM_HOST }} '
          curl -f http://localhost:3000/health
        '

    - name: Shut down containers on Azure VM
      if: always()
      run: |
        ssh -i ~/.ssh/myDockerVM_key.pem -o StrictHostKeyChecking=no ${{ secrets.AZURE_VM_USER }}@${{ secrets.AZURE_VM_HOST }} '
          cd ~/week7 && docker-compose down --volumes
        '
```
