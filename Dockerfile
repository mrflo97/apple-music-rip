# Apple Music Downloader Web UI
#
# Must run on linux/amd64 — main.py downloads Android NDK r23b (x86_64-only)
# at first launch to compile the wrapper.
FROM --platform=linux/amd64 debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    GEMINI_WRAPPED=1 \
    PYTHONUNBUFFERED=1

# Mirrors shell.nix buildInputs. GEMINI_WRAPPED=1 makes main.py skip the
# nix-shell bootstrap and use the tools installed here directly.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        curl \
        wget \
        unzip \
        cmake \
        build-essential \
        ffmpeg \
        gpac \
        bento4 \
        golang-go \
        python3 \
        python3-pip \
        python3-flask \
        python3-yaml \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

EXPOSE 5000

# Populated on first run by main.py (clone + NDK + wrapper compile + amd clone).
# Mount these as volumes so the work persists across restarts and so downloaded
# music ends up on the host.
VOLUME ["/app/wrapper", "/app/apple-music-downloader", "/app/deps"]

CMD ["python3", "main.py"]
