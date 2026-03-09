# ============================================================
# Stage 1: Build the picoclaw binary
# ============================================================
FROM golang:1.25-alpine AS builder

RUN apk add --no-cache git make

WORKDIR /src

# Cache dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source and build (single platform with WhatsApp native support)
COPY . .
RUN make generate && \
    CGO_ENABLED=0 go build -tags whatsapp_native \
    -ldflags "-X github.com/sipeed/picoclaw/cmd/picoclaw/internal.version=$(git describe --tags --always --dirty 2>/dev/null || echo dev) \
              -X github.com/sipeed/picoclaw/cmd/picoclaw/internal.gitCommit=$(git rev-parse --short=8 HEAD 2>/dev/null || echo dev) \
              -X github.com/sipeed/picoclaw/cmd/picoclaw/internal.buildTime=$(date +%FT%T%z) -s -w" \
    -o build/picoclaw ./cmd/picoclaw

# ============================================================
# Stage 2: Minimal runtime image
# ============================================================
FROM alpine:3.23

RUN apk add --no-cache ca-certificates tzdata curl

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost:18790/health || exit 1

# Copy binary
COPY --from=builder /src/build/picoclaw /usr/local/bin/picoclaw

# Create non-root user
RUN addgroup -g 1000 picoclaw && \
    adduser -D -u 1000 -G picoclaw picoclaw && \
    mkdir -p /home/picoclaw/.picoclaw && \
    chown -R picoclaw:picoclaw /home/picoclaw/.picoclaw

USER picoclaw

# Run onboard to create initial directories and config
RUN /usr/local/bin/picoclaw onboard

ENTRYPOINT ["picoclaw"]
CMD ["gateway"]
