# ================================
# Build image
# ================================
FROM swift:5.5-focal as build

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN swift build -c release

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/Tik-Tok-TTS-Bot" ./

ENTRYPOINT ["./Tik-Tok-TTS-Bot"]
