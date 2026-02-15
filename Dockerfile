# syntax=docker/dockerfile:1

FROM node:22-bookworm AS builder
WORKDIR /app
ARG CLOUDCLI_VERSION
RUN git clone --depth 1 --branch ${CLOUDCLI_VERSION} https://github.com/siteboon/claudecodeui.git .
RUN --mount=type=cache,target=/root/.npm \
    npm ci
# Workaround: process.cwd() in Settings.jsx is not defined in browsers.
# Replace with "/" (only used as fallback for project path in login handlers).
RUN sed -i "s/process\.cwd()/'\/'/g" src/components/Settings.jsx
# Fix Claude Agent SDK spawn issue in Docker containers (https://github.com/anthropics/claude-code/issues/4383)
# Add env.PATH to SDK query options to ensure NODE spawns correctly
RUN sed -i '/const queryInstance = query({/,/});/s/options: sdkOptions/options: { ...sdkOptions, env: { ...sdkOptions.env, PATH: process.env.PATH } }/' server/claude-sdk.js
RUN npm run build
# Install Claude Code CLI in builder (needs build tools for native deps)
RUN --mount=type=cache,target=/root/.npm \
    npm install -g @anthropic-ai/claude-code

FROM node:22-bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends tini git ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/local/bin/node /usr/bin/node
WORKDIR /app

# Copy Claude Code CLI from builder
COPY --from=builder /usr/local/lib/node_modules/@anthropic-ai /usr/local/lib/node_modules/@anthropic-ai
COPY --from=builder /usr/local/bin/claude /usr/local/bin/claude

# Copy only runtime-necessary files from builder
COPY --from=builder --chown=1000:1000 /app/package.json /app/package-lock.json ./
COPY --from=builder --chown=1000:1000 /app/node_modules ./node_modules
COPY --from=builder --chown=1000:1000 /app/server ./server
COPY --from=builder --chown=1000:1000 /app/shared ./shared
COPY --from=builder --chown=1000:1000 /app/dist ./dist
COPY --from=builder --chown=1000:1000 /app/public ./public

ENV NODE_ENV=production
ENV PORT=3001
EXPOSE 3001

LABEL org.opencontainers.image.title="CloudCLI" \
      org.opencontainers.image.description="Web UI for Claude Code, based on Claude Code UI" \
      org.opencontainers.image.source="https://github.com/takuyaa/cloudcli-docker" \
      org.opencontainers.image.licenses="GPL-3.0"

# Ensure writable directories for non-root user
RUN mkdir -p /home/node/.claude /data \
    && chown -R 1000:1000 /home/node /data
USER 1000

ENTRYPOINT ["tini", "--"]
CMD ["node", "server/index.js"]
