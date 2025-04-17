FROM barichello/godot-ci:4.4 AS builder

ARG GODOT_PROJECT_PATH=./
WORKDIR /app/
COPY . /app/
RUN godot --headless --verbose --export-release "Linux" --path /app
RUN ls -l /app

FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl1.1 ca-certificates \
    libx11-6 libxcursor1 libxinerama1 libxrandr2 libxi6 libasound2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --system --create-home --shell /bin/bash appuser
WORKDIR /home/appuser
COPY --from=builder /app/GodotRelayServer .
COPY --from=builder /app/GodotRelayServer.pck .
RUN chmod +x ./GodotRelayServer
RUN chown -R appuser:appuser /home/appuser
USER appuser
EXPOSE 7777

CMD ["./GodotRelayServer", "--headless", "--verbose", "res://main.tscn"]