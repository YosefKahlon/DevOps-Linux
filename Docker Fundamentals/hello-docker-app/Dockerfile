# Use the latest Node.js image as the base image
FROM node:latest


# Set the working directory inside the container
WORKDIR /app


# Copy package.json and package-lock.json to the working directory
COPY package*.json ./


# Install the dependencies
RUN npm install


# Copy the rest of the application code to the working directory
COPY . .


# Expose the port the app runs on
EXPOSE 3000



# Command to run the application
CMD ["npm", "start"]