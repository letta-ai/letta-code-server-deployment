# Letta Code Remote Deployment

Deploy a [Letta Code](https://docs.letta.com/letta-code) remote environment to any cloud platform. Runs `letta server` so your agent is always-on and accessible from [chat.letta.com](https://chat.letta.com).

## How it works

`letta server` opens an outbound WebSocket to Letta Cloud. No inbound ports, no reverse proxy, no domain name needed. Just a machine with Node.js.

## Authentication

On first deploy, `letta server` starts an OAuth device flow and prints an authorization URL in the logs. Open the URL, approve the request, and the server connects. Auth tokens are persisted under `~/.letta/`, so container deployments need a persistent volume mounted at `/root` to survive restarts.

OAuth is the only authentication method on Pro, Max-lite, and Max plans. On Developer plans, you can alternatively set `LETTA_API_KEY` as an environment variable to skip OAuth.

If you set `LETTA_BASE_URL` to a self-hosted server, device flow is not available. Use `LETTA_API_KEY`.

## Quick start (Docker)

```bash
cp .env.example .env
docker compose up -d
docker compose logs -f
# Check the logs for the OAuth URL and approve it in your browser
```

The included `docker-compose.yml` mounts `letta-data` at `/root`, so auth survives container restarts.

## Deploy to a cloud platform

### DigitalOcean

SSH into a $4/mo droplet and run directly:

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs python3 make g++
npm install -g @letta-ai/letta-code

letta server --env-name "cloud"
# Check the output for the OAuth URL and approve it in your browser
```

Or use Docker:

```bash
apt-get install -y docker.io docker-compose-v2
git clone https://github.com/letta-ai/letta-code-server-deployment.git
cd letta-code-server-deployment
cp .env.example .env
# Edit .env
docker compose up -d
```

If you bootstrap with OAuth over SSH, the saved auth state under `/root/.letta` is reused across restarts.

### Fly.io

```bash
fly launch --name letta-remote --no-deploy
fly volumes create letta_data --region sjc --size 1
fly deploy
fly logs --app letta-remote
# Check the logs for the OAuth URL and approve it in your browser
```

The included `fly.toml` mounts `/root`, so auth survives machine restarts.

### Railway

1. Connect this repo in [Railway](https://railway.app)
2. Add a persistent volume mounted at `/root`
3. Deploy
4. Open the deploy logs, find the OAuth URL, and approve it in your browser

Or via CLI:

```bash
railway init
railway up
railway logs
# Check the logs for the OAuth URL and approve it in your browser
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LETTA_API_KEY` | optional | Your Letta API key from [app.letta.com](https://app.letta.com). Developer plans only. If unset, the server uses OAuth device flow. Required for self-hosted deployments. |
| `ENV_NAME` | `cloud` | Name shown in the environment picker on chat.letta.com |
| `LETTA_BASE_URL` | `https://api.letta.com` | Override for self-hosted Letta servers. |

## Verify

1. Deploy using any method above
2. Open [chat.letta.com](https://chat.letta.com)
3. Select your environment from the picker
4. Send a message

## Docs

- [Remote environments](https://docs.letta.com/letta-code/remote)
- [Letta Code](https://docs.letta.com/letta-code)
