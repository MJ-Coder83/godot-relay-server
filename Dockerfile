FROM barichello/godot-ci:4.2 AS builder

ARG GODOT_PROJECT_PATH=./
WORKDIR /app/
COPY . /app/
RUN mkdir -v -p /app/build/linux
RUN godot --headless --verbose --export-release "Linux" ./build/linux/GodotRelayServer --path /app
RUN ls -l /app/build/linux

FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl1.1 ca-certificates \
    libx11-6 libxcursor1 libxinerama1 libxrandr2 libxi6 libasound2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --system --create-home --shell /bin/bash appuser
WORKDIR /home/appuser
COPY --from=builder /app/build/linux/GodotRelayServer .
COPY --from=builder /app/build/linux/GodotRelayServer.pck .
RUN chmod +x ./GodotRelayServer
RUN chown -R appuser:appuser /home/appuser
USER appuser
EXPOSE 7777

CMD ["./GodotRelayServer", "--headless", "--verbose", "res://main.tscn"]