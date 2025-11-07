FROM golang:bullseye

# Install build dependencies that are required by the Makefile and runtime
# helpers. curl is used by wait-for-s3.sh to poll the Minio service before the
# application starts.
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        make \
        gcc \
        libc-dev \
        git \
        curl \
    && rm -rf /var/lib/apt/lists/*

RUN go install github.com/jstemmer/go-junit-report/v2@latest

WORKDIR /app

# Copy go module manifests and download dependencies separately in order to
# leverage Docker layer caching when the source code changes.
COPY go.mod go.sum ./
RUN go mod download

# Copy the remainder of the source tree into the image so that the container
# can build and run the application without relying on bind mounts.
COPY . .

EXPOSE 8080

# The application is started via the Makefile which compiles the Linux binary
# and then launches it with the expected configuration.
CMD ["make", "run"]
