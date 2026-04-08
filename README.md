# Letta Code Remote Deployment

Deploy a [Letta Code](https://docs.letta.com/letta-code) remote environment to any cloud platform. Runs `letta server` so your agent is always-on and accessible from [chat.letta.com](https://chat.letta.com).

## How it works

`letta server` opens an outbound WebSocket to Letta Cloud. No inbound ports, no reverse proxy, no domain name needed. Just a machine with Node.js.

## Quick start (Docker)

```bash
cp .env.example .env
# Edit .env with your LETTA_API_KEY

docker compose up -d
```

## Deploy to a cloud platform

### DigitalOcean

SSH into a $4/mo droplet and run directly:

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
npm install -g @letta-ai/letta-code

export LETTA_API_KEY="your-api-key"
letta server --env-name "cloud"
```

Or use Docker:

```bash
apt-get install -y docker.io docker-compose-v2
git clone https://github.com/cpfiffer/letta-remote-deployment.git
cd letta-remote-deployment
cp .env.example .env
# Edit .env
docker compose up -d
```

### Fly.io

```bash
fly launch --name letta-remote --no-deploy
fly secrets set LETTA_API_KEY="your-api-key"
fly deploy
fly scale count 1
```

### Railway

1. Connect this repo in [Railway](https://railway.app)
2. Add `LETTA_API_KEY` and `ENV_NAME` as environment variables
3. Deploy

Or via CLI:

```bash
railway init
railway variables set LETTA_API_KEY="your-api-key"
railway up
```

### Modal

Create a secret and launch a sandbox:

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

Or SSH in: `daytona ssh letta-remote`

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LETTA_API_KEY` | (required) | Your Letta API key from [app.letta.com](https://app.letta.com) |
| `ENV_NAME` | `cloud` | Name shown in the environment picker on chat.letta.com |

## Verify

1. Deploy using any method above
2. Open [chat.letta.com](https://chat.letta.com)
3. Select your environment from the picker
4. Send a message

## Docs

- [Remote environments](https://docs.letta.com/letta-code/remote)
- [Letta Code](https://docs.letta.com/letta-code)
