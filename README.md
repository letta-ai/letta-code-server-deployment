# Letta Code Remote Deployment

Deploy a [Letta Code](https://docs.letta.com/letta-code) remote environment to any cloud platform. Runs `letta server` so your agent is always-on and accessible from [chat.letta.com](https://chat.letta.com).

## How it works

`letta server` opens an outbound WebSocket to Letta Cloud. No inbound ports, no reverse proxy, no domain name needed. Just a machine with Node.js.

## Authentication

For Letta Cloud, there are two auth paths:

- `LETTA_API_KEY`. Simplest. Set it and the server starts immediately.
- OAuth device flow. If `LETTA_API_KEY` is unset, `letta server` prints a URL and code to stdout. Open the URL in your browser, approve it, and the server finishes booting.

OAuth state is persisted under `~/.letta/`, so container deployments need a persistent volume mounted at `/root`.

If you set `LETTA_BASE_URL` to a self-hosted server, device flow is not available. Use `LETTA_API_KEY`.

## Quick start (Docker)

```bash
cp .env.example .env
# Option A: set LETTA_API_KEY in .env
# Option B: leave it blank and watch the logs for the OAuth URL

docker compose up -d
docker compose logs -f
```

The included `docker-compose.yml` mounts `letta-data` at `/root`, so OAuth survives container restarts.

## Deploy to a cloud platform

### DigitalOcean

SSH into a $4/mo droplet and run directly:

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
npm install -g @letta-ai/letta-code

# Option A: set an API key
export LETTA_API_KEY="your-api-key"
letta server --env-name "cloud"

# Option B: unset LETTA_API_KEY and complete the device flow from the printed URL
unset LETTA_API_KEY
letta server --env-name "cloud"
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

# Create a persistent volume for auth and state
fly volumes create letta_data --region sjc --size 1

# Option A: set an API key
fly secrets set LETTA_API_KEY="your-api-key"
# Option B: skip and complete device auth from the logs

fly deploy
fly logs --app letta-remote
```

The included `fly.toml` mounts `/root`, so OAuth survives machine restarts.

### Railway

1. Connect this repo in [Railway](https://railway.app)
2. Add a persistent volume mounted at `/root`
3. Either set `LETTA_API_KEY`, or leave it unset and watch the deploy logs for the OAuth URL
4. Deploy

Or via CLI:

```bash
railway init
# Option A: set an API key
railway variables set LETTA_API_KEY="your-api-key"
# Option B: skip and complete device auth from the logs
railway up
```

### Modal

The included `modal_launch.py` uses a Modal secret for the API-key path:

```bash
modal secret create letta-secrets LETTA_API_KEY="your-api-key"
python modal_launch.py
```

Modal sandboxes have a 24-hour max timeout. Re-run the script daily or set up a cron.

### Daytona

```bash
brew install daytonaio/cli/daytona
daytona login --api-key=YOUR_DAYTONA_API_KEY

daytona create --name letta-remote \
  --dockerfile Dockerfile \
  --env LETTA_API_KEY="your-api-key" \
  --auto-stop 0
```

Daytona overrides the Dockerfile CMD, so start the server manually:

```bash
daytona exec letta-remote -- letta server --env-name "daytona" --debug
```

If you omit `LETTA_API_KEY`, the device-flow URL prints in the terminal when you start the server.

Or SSH in: `daytona ssh letta-remote`

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LETTA_API_KEY` | optional | Your Letta API key from [app.letta.com](https://app.letta.com). Optional on Letta Cloud, required for self-hosted deployments. |
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
