# ============================================================================
# Vehicle Management System (VMS) — Frontend Container
# Multi-stage build: Flutter Web Compilation -> High-Performance Nginx Server
# ============================================================================

# Stage 1: Build Flutter Web assets
FROM instrumentisto/flutter:3.41 AS build
WORKDIR /app

# Cache dependencies
COPY pubspec.yaml ./
RUN flutter pub get

# Copy source and verify code quality with static analysis and test suite
COPY . .
RUN flutter analyze
RUN flutter test
RUN flutter build web --release --no-web-resources-cdn

# Stage 2: Serve via Nginx
FROM nginx:1.27-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY web-nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

HEALTHCHECK --interval=20s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/ >/dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]
