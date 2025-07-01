# Backend Dockerfile
# backend/Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/api/health || exit 1

# Start the application
CMD ["npm", "start"]

---

# Frontend Dockerfile
# frontend/Dockerfile
FROM node:18-alpine as build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy build files to nginx
COPY --from=build /app/build /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

---

# docker-compose.yml
version: '3.8'

services:
  # DynamoDB Local for development
  dynamodb:
    image: amazon/dynamodb-local:latest
    container_name: dynamodb-local
    command: ["-jar", "DynamoDBLocal.jar", "-sharedDb", "-dbPath", "./data"]
    ports:
      - "8000:8000"
    volumes:
      - dynamodb_data:/home/dynamodblocal/data
    working_dir: /home/dynamodblocal

  # Backend API
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: dynamodb-manager-backend
    environment:
      - NODE_ENV=development
      - PORT=3001
      - AWS_REGION=us-west-2
      - DYNAMODB_ENDPOINT=http://dynamodb:8000
      - AWS_ACCESS_KEY_ID=dummy
      - AWS_SECRET_ACCESS_KEY=dummy
      - FRONTEND_URL=http://localhost:3000
    ports:
      - "3001:3001"
    depends_on:
      - dynamodb
    volumes:
      - ./backend:/app
      - /app/node_modules
    command: npm run dev

  # Frontend React App
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: dynamodb-manager-frontend
    environment:
      - REACT_APP_API_URL=http://localhost:3001/api
    ports:
      - "3000:80"
    depends_on:
      - backend

  # Admin tools for DynamoDB
  dynamodb-admin:
    image: aaronshaf/dynamodb-admin:latest
    container_name: dynamodb-admin
    environment:
      - DYNAMO_ENDPOINT=http://dynamodb:8000
      - AWS_REGION=us-west-2
      - AWS_ACCESS_KEY_ID=dummy
      - AWS_SECRET_ACCESS_KEY=dummy
    ports:
      - "8001:8001"
    depends_on:
      - dynamodb

volumes:
  dynamodb_data:

---

# frontend/nginx.conf
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html index.htm;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Handle React Router
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # API proxy to backend
    location /api {
        proxy_pass http://backend:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $