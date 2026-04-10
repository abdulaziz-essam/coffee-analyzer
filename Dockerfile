# Multi-stage Dockerfile for Flutter CV Application

# Stage 1: Build the Flutter web application
FROM ubuntu:22.04 AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
ENV FLUTTER_VERSION=3.27.1
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME}

# Pre-download Flutter dependencies
RUN flutter precache --web

# Set working directory
WORKDIR /app

# Copy the UI directory (which contains the main Flutter app)
COPY UI/ /app/

# Get Flutter dependencies
RUN flutter pub get

# Build the web application
RUN flutter build web --release

# Stage 2: Serve the application with nginx
FROM nginx:alpine

# Copy the built web app from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration if needed
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
