# syntax=docker/dockerfile:1

# ---- Stage 1: build ----
# A full Go toolchain, used only to compile. None of it ends up in the final
# image.
FROM golang:1.27 AS build
WORKDIR /src

# Copy only the module files and download dependencies first. Docker caches
# each step, so as long as go.mod and go.sum don't change, later builds skip
# this download even when the code does change.
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# CGO_ENABLED=0 builds a fully static binary that needs no C libraries, so it
# can run in the minimal image below. -trimpath leaves your local file paths
# out of the binary, and -ldflags="-s -w" strips debug symbols to make it
# smaller.
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/server .

# ---- Stage 2: run ----
# Distroless "static" contains almost nothing: no shell, no package manager,
# just CA certificates (needed for HTTPS calls to Gemini and Firebase),
# timezone data, and a non-root user. Less in the image means less to attack.
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=build /out/server /server

# Run as an unprivileged user rather than root.
USER nonroot:nonroot

# Documents the port the server listens on (it reads PORT, default 8080).
EXPOSE 8080

ENTRYPOINT ["/server"]
