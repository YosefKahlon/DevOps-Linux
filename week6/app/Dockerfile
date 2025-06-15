# Use the latest Node.js image as the base image
FROM node:latest

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (if present)
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Command to run the application
CMD ["npm", "start"]

# HEALTHCHECK instruction to monitor container health
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:3000 || exit 1
