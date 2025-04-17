# --- Stage 1: Build the Godot headless server export ---
# Using barichello image as it pulls successfully
FROM barichello/godot-ci:4.4 AS builder

# Set up the build environment
ARG GODOT_PROJECT_PATH=./
WORKDIR /app/
COPY . /app/

# Create the export directory
RUN mkdir -v -p /app/build/linux

# Build command (using preset "Linux", no dedicated_server flag)
RUN godot --headless --verbose --export-release "Linux" ./build/linux/GodotRelayServer --path /app

# --- Stage 2: Create the final minimal image ---
# Use a minimal base image like Debian slim
FROM debian:bullseye-slim

# Install runtime dependencies for Godot headless server
# Add common libraries sometimes needed by standard exports
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl1.1 \
    ca-certificates \
    libx11-6 libxcursor1 libxinerama1 libxrandr2 libxi6 libasound2 && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user to run the application
RUN useradd --system --create-home --shell /bin/bash appuser
WORKDIR /home/appuser

# Copy exported binary and data pack from the builder stage
COPY --from=builder /app/build/linux/GodotRelayServer .
COPY --from=builder /app/build/linux/GodotRelayServer.pck .

# === NEW: Ensure execute permissions ===
RUN chmod +x ./GodotRelayServer

# Change ownership to the non-root user
RUN chown -R appuser:appuser /home/appuser

# Switch to the non-root user
USER appuser

# Expose the port (for documentation)
EXPOSE 7777

# === UPDATED: Run the debug script directly ===
# CMD ["./GodotRelayServer", "--headless", "--verbose"] # Original CMD
CMD ["./GodotRelayServer", "--headless", "--verbose", "--script", "res://debug_runner.gd"]