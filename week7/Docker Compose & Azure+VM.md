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




