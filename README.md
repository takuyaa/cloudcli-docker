# cloudcli-docker

Dockerized [Claude Code UI](https://github.com/siteboon/claudecodeui) - Web interface for Claude Code.

## Quick Start

### Recommended: UI Login

```bash
docker run -d \
  -e DATABASE_PATH=/data/auth.db \
  -v cloudcli-data:/data \
  -v cloudcli-claude:/home/node/.claude \
  -p 3001:3001 \
  ghcr.io/takuyaa/cloudcli:latest
```

Access the UI at `http://localhost:3001`, then:
1. Create an account
2. Go to **Settings > Account > Login** to authenticate with Claude Max/Pro
3. Credentials are saved to the volume and persist across restarts

### Alternative: API Key (pay-per-use)

If you prefer to use an API key instead of UI login:

```bash
docker run -d \
  -e ANTHROPIC_API_KEY=<your-api-key> \
  -e DATABASE_PATH=/data/auth.db \
  -v cloudcli-data:/data \
  -p 3001:3001 \
  ghcr.io/takuyaa/cloudcli:latest
```

## Environment Variables

| Variable            | Default                        | Description                     |
| ------------------- | ------------------------------ | ------------------------------- |
| `ANTHROPIC_API_KEY` | (optional)                     | Anthropic API key (pay-per-use) |
| `PORT`              | `3001`                         | Server listen port              |
| `DATABASE_PATH`     | `/app/server/database/auth.db` | SQLite database file path       |
| `NODE_ENV`          | `production`                   | Node.js environment             |

> [!NOTE]
> Authentication can be done entirely through the UI (Settings > Account > Login). Environment variables are optional for pre-configured deployments.

## Data Persistence

To persist data across container restarts, mount volumes:

```bash
docker run -d \
  -e ANTHROPIC_API_KEY=<your-api-key> \
  -e DATABASE_PATH=/data/auth.db \
  -v cloudcli-data:/data \
  -v cloudcli-claude:/home/node/.claude \
  -p 3001:3001 \
  ghcr.io/takuyaa/cloudcli:latest
```

| Volume               | Purpose                                 |
| -------------------- | --------------------------------------- |
| `/data`              | SQLite database (auth.db)               |
| `/home/node/.claude` | Claude CLI credentials and session data |

## Building from Source

```bash
# Clone this repository
git clone https://github.com/takuyaa/cloudcli-docker.git
cd cloudcli-docker

# Build (specify VERSION)
make build VERSION=v1.16.4

# Or build and push to GHCR
export GITHUB_TOKEN=<your-token>
make login
make build-push VERSION=v1.16.4
```

## Modifications from Upstream

This Docker image includes a patch to fix a browser compatibility issue in the upstream project:
- Fixed `process.cwd()` usage in `src/components/Settings.jsx` which causes `ReferenceError` in production builds

## License

This project inherits the [GPL-3.0 license](https://github.com/siteboon/claudecodeui/blob/main/LICENSE) from the upstream Claude Code UI project.

## Links

- **Upstream Project**: https://github.com/siteboon/claudecodeui
- **Docker Image**: https://ghcr.io/takuyaa/cloudcli
- **Source Code**: https://github.com/takuyaa/cloudcli-docker
