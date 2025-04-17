# --- Stage 1: Build the Godot headless server export ---
# Use a Godot export image (choose one matching your Godot version, e.g., 4.4)
# Find images here: https://github.com/godotengine/docker-builds
#FROM barichello/godot-ci:4.4 AS builder
FROM godotengine/godot:4.4-stable AS builder

# Set up the build environment
ARG GODOT_PROJECT_PATH=./
WORKDIR /app/
COPY . /app/

# Create the export directory
RUN mkdir -v -p /app/build/linux

# Export the project using the Linux preset (assuming it's named "Linux/X11")
# Ensure the preset name matches exactly what you configured in Step 7.
# The output binary name will be derived from your project name (e.g., GodotRelayServer).
# Replace 'GodotRelayServer' below if your project name is different.
RUN godot --headless --verbose --export-release "Linux" ./build/linux/GodotRelayServer --path /app

# --- Stage 2: Create the final minimal image ---
# Use a minimal base image like Debian slim
FROM debian:bullseye-slim

# Install runtime dependencies for Godot headless server
# libssl is needed for networking (ENet)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl1.1 \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user to run the application
RUN useradd --system --create-home --shell /bin/bash appuser
WORKDIR /home/appuser

# Copy only the exported binary from the builder stage
COPY --from=builder /app/build/linux/GodotRelayServer .
# Copy the project data pack (contains scenes, scripts, assets)
COPY --from=builder /app/build/linux/GodotRelayServer.pck .

# Change ownership to the non-root user
RUN chown -R appuser:appuser /home/appuser

# Switch to the non-root user
USER appuser

# Expose the port the server will listen on (will be overridden by Railway's PORT variable)
# This is more for documentation/convention
EXPOSE 7777

# The command to run the server
# Railway injects the $PORT environment variable
# We don't need --headless here as it's a dedicated server export
CMD ["./GodotRelayServer", "--headless"]