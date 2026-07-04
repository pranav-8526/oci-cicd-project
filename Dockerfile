# Use a lightweight Node.js base image (Alpine Linux is very small and secure)
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json first to leverage Docker cache
# This means if we only change our app code (server.js), Docker doesn't need to re-install dependencies
COPY package*.json ./

# Install only production dependencies (keeps the image small by skipping dev dependencies)
RUN npm install --only=production

# Copy the rest of the application code into the container
COPY . .

# Best Practice: Do not run your application as the root user for security reasons.
# Alpine image comes with a built-in 'node' user that we can switch to.
USER node

# Document the port that the application will run on
EXPOSE 8080

# Define the command to start the application when the container runs
CMD ["npm", "start"]
