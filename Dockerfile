# --- Stage 1: Build the Godot headless server export ---
# Downgrade builder image to Godot 4.2 stable
FROM barichello/godot-ci:4.2 AS builder # <--- CHANGE VERSION HERE

ARG GODOT_PROJECT_PATH=./
WORKDIR /app/
COPY . /app/
RUN mkdir -v -p /app/build/linux
# Export standard Linux build (preset "Linux", NO Embed Pck)
RUN godot --headless --verbose --export-release "Linux" ./build/linux/GodotRelayServer --path /app

# --- Stage 2: Create the final image using standard Debian ---
FROM debian:bullseye

# Install runtime dependencies for Godot 4.2 on Debian Bullseye
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl1.1 ca-certificates \
    libx11-6 libxcursor1 libxinerama1 libxrandr2 libxi6 libasound2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user, copy files, set permissions
RUN useradd --system --create-home --shell /bin/bash appuser
WORKDIR /home/appuser
COPY --from=builder /app/build/linux/GodotRelayServer .
COPY --from=builder /app/build/linux/GodotRelayServer.pck . # Copy PCK again
RUN chmod +x ./GodotRelayServer
RUN chown -R appuser:appuser /home/appuser
USER appuser
EXPOSE 7777

# === Run the MAIN scene normally ===
CMD ["./GodotRelayServer", "--headless", "--verbose", "res://main.tscn"]