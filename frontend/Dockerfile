# Use Node.js image as the base image
FROM node:14.17.0-alpine3.13

# Set the working directory to /app
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Build the production-ready application
RUN npm run build

# Start the server
CMD ["npm", "run", "serve"]