# Docker & Containers


## General conceft 
### what is Docker
Docker is an open platform for developing, shipping, and running applications. Docker enables you to separate your applications from your infrastructure so you can deliver software quickly. With Docker, you can manage your infrastructure in the same ways you manage your applications. By taking advantage of Docker’s methodologies for shipping, testing, and deploying code quickly, you can significantly reduce the delay between writing code and running it in production.

### what is Containers
A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another. A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings.

### what is Image
A Docker image is a read-only template that contains a set of instructions for creating a container that can run on the Docker platform. It provides a convenient way to package up applications and preconfigured server environments, which you can use for your own private use or share publicly with other Docker users. Docker images are made up of layers, and each layer represents an instruction in the image’s Dockerfile. Each layer except the very last one is read-only.

### Docker Client-Server Architecture
Docker uses a client-server architecture. The Docker client talks to the Docker daemon (the server), which does the heavy lifting of building, running, and distributing your Docker containers. The Docker client and daemon can run on the same system, or you can connect a Docker client to a remote Docker daemon. The Docker client and daemon communicate using a REST API, over UNIX sockets or a network interface.

### Image vs. Container
The main difference between a Docker image and a Docker container is that an image is a template, while a container is a running instance of that template.
-   **Image:** An inert, immutable file that's essentially a snapshot of a container. Images are created with the `docker build` command. They are stored in a Docker registry, like Docker Hub.
-   **Container:** A runnable instance of an image. You can create, start, stop, move, or delete a container using the Docker API or CLI. Containers are created from images using the `docker run` command. You can create many containers from the same image.




## basic CLI commands


* to run docker we use 
```bash
docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
```

* To get (pull) an image from Docker Hub (or another registry)
You use the `docker pull` command to download an image from a registry (like Docker Hub by default) to your local machine. This makes the image available for you to create containers from.

```bash
docker pull <image_name>:<tag>
```
-   `<image_name>`: The name of the image (e.g., `ubuntu`, `node`, `nginx`).
-   `<tag>`: The specific version or variant of the image (e.g., `latest`, `18.04`, `alpine`). If you omit the tag, Docker defaults to `latest`.

```
To pull the latest version of the official Nginx image:
```bash
docker pull nginx
```
Or, more explicitly:
```bash
docker pull nginx:latest
```
If the image is already present locally, Docker will check if there's a newer version in the registry and download it if available. If you run `docker run <image_name>` and the image is not yet local, Docker will automatically attempt to pull it first.


* we can use the lightweight image of nginx
```bash
docker pull nginx:alpine
```

the diffrent bettwein 

nginx                                                    latest          be69f2940aaf   7 weeks ago    192MB
nginx                                                    alpine          6769dc3a703c   7 weeks ago    48.2MB


* list of all imgaes, give as detile about repository, tag, when created, size
  
```bash
docker images
```

Alternatively, you can use:
```bash
docker image ls
```
Both `docker images` and `docker image ls` are aliases and provide the exact same output, listing all local images with details such as repository, tag, image ID, creation date, and size. The `docker image ls` syntax is part of a newer Docker CLI structure that groups commands by the object they manage (e.g., `container`, `volume`, `network`). The shorter `docker images` command is maintained for backward compatibility.

for example we can compere nginx:alpine aginst nginx:latest
```bash        
nginx  latest          be69f2940aaf   7 weeks ago    192MB
nginx  alpine          6769dc3a703c   7 weeks ago    48.2MB
```



* list of all runing docker 
```bash
docker ps

* to stop docker we use
To stop a running Docker container, you first need to find its container ID or name. You can list all running containers using `docker ps`.
Once you have the ID or name, you can use the `docker stop` command:
```bash
docker stop <container_id_or_name>
```
For example, if a container has the ID `a1b2c3d4e5f6`, you would run:
```bash
docker stop a1b2c3d4e5f6
```
This command sends a SIGTERM signal to the main process inside the container. If the process doesn't stop within a grace period (default 10 seconds), a SIGKILL signal is sent.

You can also stop all running containers at once with a command like:
```bash
docker stop $(docker ps -q)
```


* list of runing and stoped continer

```bash
docker ps -a
```

* to remove

**Removing Stopped Containers**

To remove a specific stopped container, you use the `docker rm` command followed by the container ID or name. You can get the ID or name from `docker ps -a`.

```bash
docker rm <container_id_or_name>
```
For example:
```bash
docker rm my_container_name
docker rm a1b2c3d4e5f6
```

To remove all stopped containers, you can use the `docker container prune` command:
```bash
docker container prune
```
This will ask for confirmation before proceeding.
Alternatively, you can combine commands to remove all stopped containers (use with caution):
```bash
docker rm $(docker ps -aq)
```

**Removing Images**

To remove a specific image, you use the `docker rmi` command followed by the image ID or name/tag. You can get the image ID or name from `docker images`.

```bash
docker rmi <image_id_or_name:tag>
```
For example:
```bash
docker rmi my_image:latest
docker rmi 2a0e88067d31
```
Note: You cannot remove an image if it is currently being used by any container (even a stopped one). You must remove the container(s) first.

To remove all unused (dangling) images (images that are not tagged and are not referenced by any container):
```bash
docker image prune
```

To remove all unused images, not just dangling ones (this will remove all images that don't have at least one container associated with them):
```bash
docker image prune -a
```
Both `prune` commands will ask for confirmation.

### `docker stop` vs. `docker rm`

It's important to understand the difference between stopping and removing a container:

*   **`docker stop <container_id_or_name>`**: This command stops a *running* container. The container's process is terminated, but the container itself still exists on your system in a "stopped" state. Its file system, configuration, and any data not stored in a volume are preserved. You can restart a stopped container later using `docker start <container_id_or_name>`.
    *   Think of it like turning off a computer: the machine is powered down, but all its files and settings remain.

*   **`docker rm <container_id_or_name>`**: This command removes a *stopped* container. This action permanently deletes the container, including its file system and any associated data (unless that data is stored in a Docker volume). Once a container is removed, it cannot be started again. If you need to run the application again, you would create a new container from its image.
    *   You cannot directly remove a running container with `docker rm`; you must stop it first or use the force flag (`docker rm -f <container_id_or_name>`).
    *   Think of this like formatting a hard drive and throwing away the computer: the data and the machine are gone.

### When to Remove an Image vs. a Container

*   **Remove a Container (`docker rm`)**: You remove a container when you no longer need that specific instance of an application. For example:
    *   You finished a temporary task that the container was running.
    *   The container has exited and you don't need its logs or filesystem anymore.
    *   You want to start a fresh instance from the same image with a different configuration.
    The image from which the container was created remains on your system, allowing you to create new containers from it.

*   **Remove an Image (`docker rmi`)**: You remove an image when you no longer need the image template itself. This is typically done to:
    *   Free up disk space, as images can be quite large.
    *   Remove outdated or superseded versions of an image.
    *   Clean up images from projects you are no longer working on.
    *   **Important**: You cannot remove an image if it is currently being used by any container (even a stopped one). You must first remove all containers that were created from that image using `docker rm` before you can remove the image itself with `docker rmi`.

### Exposing Ports (`-p` flag)

When you run a container that hosts a service (like a web server or a database), you often need to access that service from your host machine or other machines on your network. By default, ports on a Docker container are not accessible from the host. Docker's port mapping feature allows you to expose a container's internal port to a port on the host machine.

This is done using the `-p` (or `--publish`) flag with the `docker run` command.

The syntax is:
```bash
docker run -p <host_port>:<container_port> <image_name>
```
-   `<host_port>`: The port on your Docker host machine that will forward traffic to the container.
-   `<container_port>`: The port inside the container that the application is listening on (can find the port when do docker ps).


**Example: Running an Nginx Web Server**

The Nginx web server, by default, listens on port 80 inside its container.

1.  **Run Nginx and map port 8080 on the host to port 80 in the container:**
    To make the Nginx server accessible on port 8080 of your host machine, you would run:
    ```bash
    docker run -d -p 8080:80 nginx
    ```
    -   `-d`: Runs the container in detached mode (in the background).
    -   `-p 8080:80`: Maps port 8080 on the host to port 80 inside the Nginx container.
    -   `nginx`: The name of the image to use.

2.  **Verify the Nginx server is running:**
    You can now access the Nginx default page from your host machine.

    *   **Using `curl` (from your host machine's terminal):**
        ```bash
        curl localhost:8080
        ```
        You should see the HTML content of the Nginx welcome page.

    *   **Using a web browser (on your host machine):**
        Open your web browser and navigate to:
        ```
        http://localhost:8080
        ```
        You should see the Nginx welcome page.

3.  **To stop and remove the container (once you're done):**
    First, find the container ID:
    ```bash
    docker ps
    ```
    Then stop and remove it:
    ```bash
    docker stop <container_id>
    docker rm <container_id>
    ```

**Other Port Mapping Options:**

*   **Map to a specific IP address on the host:**
    ```bash
    docker run -d -p 192.168.1.100:8080:80 nginx
    ```
    This makes the service available only on that specific IP address of the host.

*   **Let Docker choose a random available host port:**
    If you only specify the container port, Docker will automatically choose a random unused high-numbered port on the host.
    ```bash
    docker run -d -p 80 nginx
    ```
    You can then use `docker ps` or `docker port <container_name_or_id> 80` to find out which host port was assigned.


## Dockerfile Basics
To create our own image we creat a Dockerfile. This file contains a set of instructions Docker uses to build the image.

Here's an example `Dockerfile` for a basic Node.js application:

```Dockerfile
# Use the latest Node.js image as the base image
FROM node:latest

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
# This step is separate to leverage Docker's layer caching.
# If package*.json hasn't changed, Docker can reuse the layer from a previous build
# where dependencies were installed, speeding up the build process.
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Expose the port the app runs on (e.g., 3000)
# This is documentation for the user and for Docker. It doesn't actually publish the port.
EXPOSE 3000

# Command to run the application when the container starts
CMD ["npm", "start"]
```

**Explanation of Dockerfile Instructions:**

*   `FROM node:latest`: Specifies the base image to use. In this case, it's the official Node.js image with the `latest` tag from Docker Hub.
*   `WORKDIR /app`: Sets the working directory for subsequent commands (`COPY`, `RUN`, `CMD`, `ENTRYPOINT`) in the Dockerfile. If the directory doesn't exist, it will be created.
*   `COPY package*.json ./`: Copies files matching `package*.json` (i.e., `package.json` and `package-lock.json`) from the build context (your project directory) into the current working directory (`/app`) inside the image.
*   `RUN npm install`: Executes the `npm install` command inside the image. This installs the dependencies defined in `package.json`. Each `RUN` command creates a new layer in the image.
*   `COPY . .`: Copies all remaining files and directories from the build context into the current working directory (`/app`) inside the image.
*   `EXPOSE 3000`: Informs Docker that the container listens on the specified network port at runtime. This is primarily for documentation and doesn't actually publish the port. You still need to use the `-p` flag with `docker run` to map the container port to a host port.
*   `CMD ["npm", "start"]`: Specifies the default command to execute when a container is run from this image. This should be in JSON array format for executable commands. It will run the `start` script defined in your `package.json`.

**Building the Image:**

To build an image from this Dockerfile, navigate to the directory containing the `Dockerfile` and your application code, then run:
```bash
docker build -t your-image-name .
```
- `-t your-image-name`: Tags the image with a name (e.g., `my-node-app`).
- `.`: Specifies the current directory as the build context.

**Running the Container:**

Once the image is built, you can run a container from it:
```bash
docker run -p <host_port>:3000 your-image-name
```
- `-p <host_port>:3000`: Maps a port on your host machine to port 3000 inside the container (the port exposed by the Node.js app). For example, `-p 8080:3000`.

### The `.dockerignore` File

When you run `docker build`, the Docker CLI sends the entire content of the directory specified as the build context (e.g., `.` for the current directory) to the Docker daemon. This can be slow and inefficient if the directory contains large files or directories that are not needed for building the image (e.g., `node_modules`, `.git` directory, build artifacts, local development files, logs).

The `.dockerignore` file allows you to specify a list of files and directories that should be excluded from the build context sent to the Docker daemon. It works similarly to a `.gitignore` file.

**Why use `.dockerignore`?**

*   **Faster Builds:** By excluding unnecessary files, you reduce the amount of data sent to the daemon, speeding up the `docker build` process.
*   **Smaller Image Size (Potentially):** While `.dockerignore` primarily affects the build context, excluding large, unneeded files can prevent them from being accidentally `COPY`ed into your image, which could otherwise increase the image size.
*   **Avoiding Unintended Overwrites:** Prevents local development files or build artifacts from overwriting files within the image during a `COPY . .` operation.
*   **Security:** Prevents sensitive files or directories (like `.git` which might contain credentials in its history, or local secret files) from being included in the build context and potentially ending up in the image.

**Example `.dockerignore` file:**

Create a file named `.dockerignore` in the same directory as your `Dockerfile` (the root of your build context).

```
# Comments are allowed

# Exclude node_modules, as dependencies will be installed inside the container
node_modules
npm-debug.log

# Exclude build artifacts or local development files
build
dist
.env

# Exclude version control directories and files
.git
.gitignore
.gitattributes

# Exclude Docker related files if they are in the context but not needed in image
Dockerfile
.dockerignore

# Exclude OS-specific files
.DS_Store
Thumbs.db
```

**Syntax:**

*   Each line specifies a pattern.
*   `#` at the beginning of a line indicates a comment.
*   Patterns are matched relative to the root of the build context.
*   You can use wildcards like `*` (matches any sequence of non-separator characters) and `**` (matches any sequence of characters, including separators).
*   A `!` prefix negates a pattern, meaning files matching that pattern will be included even if they were excluded by a previous pattern.

By using a `.dockerignore` file, especially when using broad `COPY . .` commands in your `Dockerfile`, you ensure that only the necessary files are sent to the Docker daemon and included in your image layers.

## Custom Networking and Multi-container Setup

By default, Docker uses a bridge network for containers. While this allows containers on the same host to communicate via IP addresses, it doesn't provide automatic service discovery using container names out-of-the-box for user-defined bridge networks. Custom bridge networks are recommended for better isolation and to enable easy communication between containers using their names.

**Benefits of Custom Networks:**

*   **Automatic Service Discovery:** Containers on the same custom bridge network can resolve each other by their container name. This is very useful for multi-container applications (e.g., a web application connecting to a database).
*   **Better Isolation:** Custom networks provide better isolation from containers not connected to that network.
*   **Network Aliases:** You can assign network aliases to containers, allowing them to be reached by multiple names.


**Example: Web App (Node.js) and Database (PostgreSQL)**

Let's create a more realistic example with a Node.js web application that needs to connect to a PostgreSQL database. We'll run both on a custom network called `app-network`.

*Assumptions:*
*   You have a simple Node.js application in a directory (e.g., `app`) with a `Dockerfile` and `package.json`.
*   The Node.js app is configured to connect to a PostgreSQL database using a hostname (e.g., `db`).

1.  **Create the Custom Network:**
    ```bash
    docker network create app-network
    ```

2.  **Run the PostgreSQL Database Container:**
    We'll use the official PostgreSQL image. We need to set a password for the default `postgres` user and give the container a name that our app can use as a hostname.
    ```bash
    docker run -d \
      --name postgres-db \
      --network app-network \
      -e POSTGRES_PASSWORD=mysecretpassword \
      postgres:latest
    ```
    -   `-d`: Detached mode.
    -   `--name postgres-db`: Names the container `postgres-db`. This name will be resolvable by other containers on `app-network`.
    -   `--network app-network`: Connects to our custom network.
    -   `-e POSTGRES_PASSWORD=mysecretpassword`: Sets the required password for the PostgreSQL superuser. **Use a strong password in production.**
    -   `postgres:latest`: The official PostgreSQL image.

3.  **Build and Run the Node.js Web Application Container:**
    First, navigate to your Node.js application directory (e.g., `cd /home/yosef/Documents/github/DevOps-Linux/DevOps-Linux/week6/app`).
    Build the image for your Node.js app (assuming your Dockerfile is in this directory):
    ```bash
    docker build -t my-node-app .
    ```
    Now, run the Node.js application container, connecting it to the same network and configuring it to talk to the database.
    ```bash
    docker run -d \
      --name node-app-container \
      --network app-network \
      -e DATABASE_URL=postgres://postgres:mysecretpassword@postgres-db:5432/postgres \
      my-node-app
    ```
    -   `--name node-app-container`: Names this container.
    -   `--network app-network`: Connects to the same network as the database.
    -   `-e DATABASE_URL=postgres://postgres:mysecretpassword@postgres-db:5432/postgres`: Sets an environment variable that the Node.js application can use to connect to the database. Notice we use `postgres-db` as the hostname, which is the name of our PostgreSQL container.
    -   `my-node-app`: The image we just built.

4.  **Verify Communication:**
    Check the logs of your Node.js application container to see if it successfully connected to the database.
    ```bash
    docker logs node-app-container
    ```
    If the Node.js app in `app/index.js` is set up to log connection status (as in the example provided previously), you should see a success message.

5.  **Cleanup:**
    ```bash
    docker stop node-app-container postgres-db
    docker rm node-app-container postgres-db
    docker network rm app-network
    docker rmi my-node-app # Optional: remove the app image
    ```

This example demonstrates how containers on the same custom network can easily discover and communicate with each other using their container names as hostnames, which is crucial for building microservice-based applications.

## Docker Compose: Simplifying Multi-Container Applications

While `docker run` and custom networks are powerful, managing multi-container applications with many commands can become complex. Docker Compose is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file to configure your application’s services. Then, with a single command, you create and start all the services from your configuration.

**Key Benefits of Docker Compose:**

*   **Simplified Multi-Container Management:** Define all your services, networks, and volumes in a single `docker-compose.yml` file.
*   **Single Command Operations:** Start, stop, and rebuild all services with commands like `docker-compose up`, `docker-compose down`.
*   **Configuration Consistency:** Ensures your application runs the same way in different environments (development, testing, staging).
*   **Easy Service Linking and Discovery:** Services defined in the same `docker-compose.yml` file are automatically placed on a default network (or a custom one you define) and can discover each other by their service name.

### Example: `docker-compose.yml` for Web App and Database

Let's look at the `docker-compose.yml` file you created for the Node.js web application and PostgreSQL database setup. This file typically resides at the root of your project directory.


```yaml
version: '3.8' # Specifies the version of the Docker Compose file format

services:
  web:
    build: ./app # Tells Compose to build an image from the Dockerfile in the ./app directory
    ports:
      - "8080:3000" # Maps port 8080 on the host to port 3000 in the 'web' service container
    environment:
      DATABASE_URL: postgres://postgres:mysecretpassword@db:5432/postgres # Sets environment variable for the app
    depends_on:
      - db # Specifies that the 'web' service depends on the 'db' service. Compose will start 'db' before 'web'.
    networks:
      - app-net # Connects this service to the 'app-net' network

  db:
    image: postgres:latest # Uses the official postgres:latest image from Docker Hub
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: mysecretpassword
      POSTGRES_DB: postgres
    volumes:
      - pgdata:/var/lib/postgresql/data # Mounts a named volume 'pgdata' to persist database data
    networks:
      - app-net # Connects this service to the 'app-net' network
    # To access the DB from your host machine (e.g., with pgAdmin), you can optionally expose the port:
    # ports:
    #   - "5432:5432"

volumes:
  pgdata: # Defines a named volume 'pgdata' for data persistence

networks:
  app-net: # Defines a custom bridge network 'app-net'
    driver: bridge
```

**Explanation of the `docker-compose.yml`:**

*   `version: '3.8'`: Specifies the version of the Docker Compose file syntax. It's good practice to use a recent version.
*   `services:`: This is where you define the different containers (services) that make up your application.
    *   `web:`: Defines the Node.js application service.
        *   `build: ./app`: Instructs Docker Compose to build an image from the `Dockerfile` located in the `./app` directory (relative to the `docker-compose.yml` file).
        *   `ports: - "8080:3000"`: Maps port 8080 on the host to port 3000 on the `web` container (assuming your Node.js app listens on port 3000).
        *   `environment: DATABASE_URL: ...`: Sets the `DATABASE_URL` environment variable for the `web` service. Notice the hostname for the database is `db`, which is the name of the database service defined below. Docker Compose provides DNS resolution between services on the same network.
        *   `depends_on: - db`: Tells Compose that the `web` service depends on the `db` service. Compose will start the `db` service and ensure it's running before starting the `web` service.
        *   `networks: - app-net`: Connects the `web` service to the `app-net` network.
    *   `db:`: Defines the PostgreSQL database service.
        *   `image: postgres:latest`: Uses the official `postgres:latest` image from Docker Hub.
        *   `environment: ...`: Sets environment variables required by the PostgreSQL image to initialize the database, user, and password.
        *   `volumes: - pgdata:/var/lib/postgresql/data`: Mounts a named volume called `pgdata` to the `/var/lib/postgresql/data` directory inside the `db` container. This ensures that your database data persists even if the `db` container is stopped or removed.
        *   `networks: - app-net`: Connects the `db` service to the `app-net` network.
*   `volumes:`: This top-level key defines named volumes.
    *   `pgdata:`: Declares the named volume `pgdata`. Docker manages this volume.
*   `networks:`: This top-level key defines networks.
    *   `app-net: driver: bridge`: Defines a custom bridge network named `app-net`. Services connected to this network can communicate with each other using their service names as hostnames.

### Using Docker Compose

With the `docker-compose.yml` file in place, managing your multi-container application becomes much simpler.

1.  **Starting the Application (`docker-compose up`)**
    Navigate to the directory containing your `docker-compose.yml` file (in this case, `/home/yosef/Documents/github/DevOps-Linux/DevOps-Linux/week6/`) and run:
    ```bash
    docker-compose up
    ```
    This command will:
    *   Pull any images not already present locally (like `postgres:latest`).
    *   Build images for services that have a `build` instruction (like our `web` service from `./app/Dockerfile`).
    *   Create the specified network (`app-net`) if it doesn't exist.
    *   Create the specified volume (`pgdata`) if it doesn't exist.
    *   Create and start containers for all defined services (`web` and `db`).
    *   Attach to the logs of all services and stream them to your terminal.

    To run the services in the background (detached mode), use the `-d` flag:
    ```bash
    docker-compose up -d
    ```

2.  **Viewing Logs**
    If you started with `docker-compose up -d`, you can view the logs for all services:
    ```bash
    docker-compose logs
    ```
    Or for a specific service:
    ```bash
    docker-compose logs web
    docker-compose logs db
    ```
    To follow the logs in real-time:
    ```bash
    docker-compose logs -f web
    ```

3.  **Testing Inter-Service Communication**
    *   **Web Application Access:** Once the services are up, your `web` application should be accessible on your host machine at `http://localhost:8080` (as defined by `ports: - "8080:3000"`).
    *   **Database Connection:** The `web` service (your Node.js app) should be able to connect to the `db` service (PostgreSQL) using the hostname `db` and the credentials specified in `DATABASE_URL`. Check the logs of the `web` service (`docker-compose logs web`) to confirm a successful database connection. If your `app/index.js` logs connection status, you should see a success message.

    You can also test connectivity from within one container to another. For example, to test if the `web` container can reach the `db` container:
    First, find the container name or ID for the `web` service:
    ```bash
    docker-compose ps
    ```
    Then, execute a command inside the `web` container (e.g., `ping db` or `nc -zv db 5432` if netcat is available in your `web` image):
    ```bash
    docker-compose exec web ping db
    ```
    Or, if your `web` container's base image has `psql` (unlikely for a minimal Node.js image, but for demonstration):
    ```bash
    # This command is illustrative; psql might not be in your 'web' container.
    # docker-compose exec web psql -h db -U postgres -d postgres -c '\conninfo'
    ```
    The key is that the `web` service can resolve `db` to the IP address of the `db` service container because they are on the same Docker Compose network (`app-net`).

4.  **Stopping the Application (`docker-compose down`)**
    To stop and remove all containers, networks, and (optionally) volumes defined in your `docker-compose.yml`, run:
    ```bash
    docker-compose down
    ```
    By default, `docker-compose down` removes containers and networks, but it does *not* remove named volumes (like `pgdata`). This is to prevent accidental data loss.
    If you also want to remove the named volumes defined in the `docker-compose.yml`, use the `-v` flag:
    ```bash
    docker-compose down -v
    ```

5.  **Other Useful Commands:**
    *   `docker-compose ps`: List containers managed by Compose.
    *   `docker-compose build`: Build or rebuild services.
    *   `docker-compose pull`: Pull service images.
    *   `docker-compose stop`: Stop services without removing them.
    *   `docker-compose start`: Start existing stopped services.
    *   `docker-compose restart`: Restart services.
    *   `docker-compose exec <service_name> <command>`: Execute a command in a running service container (e.g., `docker-compose exec web sh`).

Docker Compose significantly streamlines the development and deployment workflow for applications that consist of multiple interconnected services.

## Monitoring & Logging Basics

### HEALTHCHECK
To monitor container health, you can add a `HEALTHCHECK` instruction to your Dockerfile. For example:
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:3000 || exit 1
```
This checks if the application is reachable at `http://localhost:3000` every 30 seconds. If the check fails, Docker marks the container as unhealthy.

### Logging HTTP Requests
To log HTTP requests in your Node.js app, you can use the `morgan` middleware. Add the following to your `index.js`:
```javascript
const morgan = require('morgan');
app.use(morgan('combined'));
```
This logs all incoming HTTP requests in a combined format, which includes method, URL, status code, and response time.

### Viewing Logs
Use `docker logs` to view container logs:
```bash
docker logs <container_name_or_id>
```
To follow logs in real-time:
```bash
docker logs -f <container_name_or_id>
```

### Inspecting Container Health
Use `docker inspect` to validate container health and status:
```bash
docker inspect <container_name_or_id>
```
Look for the `State` field in the output, which includes `Health` information if a `HEALTHCHECK` is defined. For example:
```json
"State": {
  "Status": "running",
  "Health": {
    "Status": "healthy",
    "Log": [
      {
        "Start": "2025-06-10T12:00:00Z",
        "End": "2025-06-10T12:00:01Z",
        "ExitCode": 0,
        "Output": ""
      }
    ]
  }
}
```


##  Advanced Docker Features

 tag:

### Image Tagging

Docker image tags are human-readable labels or aliases that you can apply to your Docker images. They are typically used to denote versions or variants of an image. For example, an image might have tags like `myapp:1.0`, `myapp:1.1`, `myapp:latest`, or `myapp:alpine`.

**Why use tags?**

*   **Versioning:** Easily manage and deploy specific versions of your application.
*   **Clarity:** Understand what version or variant an image represents.
*   **Rollbacks:** Quickly revert to a previous, stable version if issues arise with a newer one.
*   **Organization:** Keep your image repository (like Docker Hub) organized.

**How to tag an image:**

You use the `docker tag` command to create an alias (a new tag) that refers to an existing image. The command doesn't create a new image; it just adds another reference to an existing one.

The syntax is:
```bash
docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
```

*   `SOURCE_IMAGE[:TAG]`: The name and optional existing tag of the image you want to tag. If you omit the tag, Docker assumes `:latest`. You can also use the image ID.
*   `TARGET_IMAGE[:TAG]`: The new name and tag you want to assign.

**Example:**

Let's say you have an image named `week6-web` (which might implicitly be `week6-web:latest` if you built it without a specific tag, or it might have a tag based on your build process). To tag it as `week6-web:1.0.0`:

1.  **Find your existing image ID or name:**
    ```bash
    docker images
    ```
    Look for your `week6-web` image. Let's assume its ID is `abcdef123456` or it's listed as `week6_web` (Docker Compose often prefixes with project name).

2.  **Tag the image:**
    If your current image is `week6_web:latest` (or `week6-web:latest` if you built it manually with that name):
    ```bash
    docker tag week6_web:latest yourusername/week6-web:1.0.0
    ```
    Or, if you want to tag it locally first without a username (useful before pushing to a registry):
    ```bash
    docker tag week6_web:latest week6-web:1.0.0
    ```
    If you are using the image ID:
    ```bash
    docker tag abcdef123456 week6-web:1.0.0
    ```
    And if you plan to push it to Docker Hub, it's conventional to include your Docker Hub username:
    ```bash
    docker tag week6-web:1.0.0 yourusername/week6-web:1.0.0
    ```
    (Replace `yourusername` with your actual Docker Hub username).

After tagging, if you run `docker images`, you'll see the new tag listed, pointing to the same image ID as the original.

This new tag can then be used to push the image to a registry like Docker Hub (`docker push yourusername/week6-web:1.0.0`) or to run a specific version of the container.

### Slack Notifications for Container Events

To monitor Docker container events (like start, stop, die, health_status) and receive real-time updates, a `slack-notifier` service can be integrated into your Docker Compose setup. This service listens to Docker events and sends formatted messages to a specified Slack webhook.

**Components:**

1.  **`slack-notifier/Dockerfile`**:
    *   Uses a lightweight base image (e.g., `alpine:latest`).
    *   Installs necessary tools like `curl` (to send HTTP requests to Slack), `jq` (to parse JSON from Docker events), and `docker-cli` (to interact with the Docker daemon, though direct socket access is often used).
    *   Copies a notification script (e.g., `notify.sh`) into the image.
    *   Sets the notification script as the `CMD` to run when the container starts.

    Example `slack-notifier/Dockerfile`:
    ```dockerfile
    FROM alpine:latest

    # Install curl, jq, and docker CLI for event monitoring and notification
    RUN apk add --no-cache curl jq docker-cli

    # Copy the notification script
    COPY notify.sh /usr/local/bin/notify.sh
    RUN chmod +x /usr/local/bin/notify.sh

    # Command to run the script
    CMD ["notify.sh"]
    ```

2.  **`slack-notifier/notify.sh`**:
    *   A shell script that uses `docker events` to listen for relevant container lifecycle events.
    *   Formats a message based on the event type and container information.
    *   Uses `curl` to send this message to the Slack webhook URL (provided as an environment variable).

    Example snippet from `notify.sh`:
    ```bash
    #!/bin/sh

    SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL}"
    HOST_NAME=$(hostname)

    # Function to send a notification to Slack
    send_notification() {
      MESSAGE=$1
      curl -X POST -H 'Content-type: application/json' --data "{\\"text\\":\\"$MESSAGE\\"}" "$SLACK_WEBHOOK_URL"
    }

    # Listen to Docker events
    docker events --filter event=start --filter event=stop --filter event=die --filter event=health_status \\
      --format 'Container {{.Actor.Attributes.name}} ({{.Actor.ID}}) {{.Action}} on host '$HOST_NAME'' | \\
    while read event_message
    do
      echo "Docker event: $event_message"
      send_notification "$event_message"
    done
    ```

3.  **`docker-compose.yml` Configuration**:
    *   Defines a new service (e.g., `slack-notifier`).
    *   Builds the image from the `slack-notifier` directory.
    *   Mounts the Docker socket (`/var/run/docker.sock`) as a read-only volume to allow the service to listen to Docker events.
    *   Passes the `SLACK_WEBHOOK_URL` as an environment variable.
    *   Configures `restart: always` to ensure the notifier is resilient.

    Example `slack-notifier` service in `docker-compose.yml`:
    ```yaml
    services:
      # ... other services (web, db) ...

      slack-notifier:
        build: ./slack-notifier
        restart: always
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock:ro # Read-only access to Docker socket
        environment:
          SLACK_WEBHOOK_URL: "YOUR_SLACK_WEBHOOK_URL_HERE"
        logging:
          driver: "json-file"
          options:
            max-size: "10m"
            max-file: "3"
    ```

**To Use:**

1.  Create the `slack-notifier/Dockerfile` and `slack-notifier/notify.sh` script.
2.  Update your `docker-compose.yml` to include the `slack-notifier` service, replacing `"YOUR_SLACK_WEBHOOK_URL_HERE"` with your actual Slack webhook URL.
3.  Run `docker-compose up --build -d`. The `slack-notifier` service will start monitoring Docker events and send notifications to your configured Slack channel.