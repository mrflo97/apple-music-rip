# Apple Music Downloader Web UI
#
# Must run on linux/amd64 — main.py downloads Android NDK r23b (x86_64-only)
# at first launch to compile the wrapper.
FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    GEMINI_WRAPPED=1 \
    PYTHONUNBUFFERED=1

# Mirrors shell.nix buildInputs (minus bento4, installed below). GEMINI_WRAPPED=1
# makes main.py skip the nix-shell bootstrap and use the tools installed here.
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
        golang-go \
        python3 \
        python3-pip \
        python3-flask \
        python3-yaml \
    && rm -rf /var/lib/apt/lists/*

# Bento4 isn't packaged for Debian/Ubuntu — pull the upstream prebuilt SDK.
ARG BENTO4_VERSION=1-6-0-641
RUN curl -fsSL "https://www.bok.net/Bento4/binaries/Bento4-SDK-${BENTO4_VERSION}.x86_64-unknown-linux.zip" -o /tmp/bento4.zip \
    && unzip -q /tmp/bento4.zip -d /opt \
    && mv "/opt/Bento4-SDK-${BENTO4_VERSION}.x86_64-unknown-linux" /opt/bento4 \
    && rm /tmp/bento4.zip
ENV PATH="/opt/bento4/bin:${PATH}"

WORKDIR /app
COPY . /app

EXPOSE 5000

# Populated on first run by main.py (clone + NDK + wrapper compile + amd clone).
# Mount these as volumes so the work persists across restarts and so downloaded
# music ends up on the host.
VOLUME ["/app/wrapper", "/app/apple-music-downloader", "/app/deps"]

CMD ["python3", "main.py"]
