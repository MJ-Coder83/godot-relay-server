# --- Stage 1: Build the Godot headless server export ---
# Downgrade builder image to Godot 4.3 stable
FROM barichello/godot-ci:4.3 AS builder # <--- CHANGE VERSION HERE

# Set up the build environment
ARG GODOT_PROJECT_PATH=./
WORKDIR /app/
COPY . /app/

# Create the export directory
RUN mkdir -v -p /app/build/linux

# Build command (using preset "Linux", no dedicated_server flag)
# Should work fine with 4.3 binary even if project is 4.4 (usually compatible)
RUN godot --headless --verbose --export-release "Linux" ./build/linux/GodotRelayServer --path /app

# --- Stage 2: Create the final image using standard Debian ---
FROM debian:bullseye

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Use libssl compatible with Debian Bullseye and Godot 4.3
    libssl1.1 \
    ca-certificates \
    libx11-6 libxcursor1 libxinerama1 libxrandr2 libxi6 libasound2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user, copy files, set permissions
RUN useradd --system --create-home --shell /bin/bash appuser
WORKDIR /home/appuser
COPY --from=builder /app/build/linux/GodotRelayServer .
COPY --from=builder /app/build/linux/GodotRelayServer.pck .
RUN chmod +x ./GodotRelayServer
RUN chown -R appuser:appuser /home/appuser
USER appuser
EXPOSE 7777

# === Revert CMD to run the actual server normally ===
CMD ["./GodotRelayServer", "--headless", "--verbose", "res://main.tscn"]