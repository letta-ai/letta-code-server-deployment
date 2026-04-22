# Letta Code Remote Deployment

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/letta-code-remote?utm_medium=integration&utm_source=template&utm_campaign=generic)

Deploy a [Letta Code](https://docs.letta.com/letta-code) remote environment to any cloud platform. Runs `letta server` so your agent is always-on and accessible from [chat.letta.com](https://chat.letta.com) or the [Letta Code](https://letta.com) desktop app.

## How it works

`letta server` opens an outbound WebSocket to Letta Cloud. No inbound ports, no reverse proxy, no domain name needed.

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
docker compose up -d
docker compose logs -f
# Check the logs for the OAuth URL and approve it in your browser
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

## Updating

The Dockerfile cache-busts on every new `@letta-ai/letta-code` npm release, so any redeploy after a release will pick up the latest version automatically. No config changes or `NO_CACHE=1` workarounds needed — just redeploy:

- **Railway**: click Redeploy, or push an empty commit.
- **Fly**: `fly deploy`.
- **Docker Compose**: `docker compose build --pull && docker compose up -d`.

If you want to pin a specific version instead of tracking latest, fork this repo and change the install line in the Dockerfile to `bun install -g @letta-ai/letta-code@<version>`.

## Channels (Telegram, Slack)

Letta Code [channels](https://docs.letta.com/letta-code/channels) let your agent receive and respond to messages from external platforms. Set the relevant env vars and the container bootstraps the channel config automatically on startup.

### Telegram

1. Create a bot via [@BotFather](https://t.me/BotFather), copy the token.
2. Set `TELEGRAM_BOT_TOKEN` in your service's environment.
3. Redeploy. The server starts with `--channels telegram` and the Telegram runtime installs on first boot.
4. DM the bot — it replies with a pairing code.
5. From the Letta Code desktop app (pointed at this remote server) or via shell on the service, pair the chat to an agent:

   ```bash
   letta channels pair --channel telegram --code <code> --agent <agent-id>
   ```

### Slack

1. Create a Slack app using the [manifest in the Letta Code docs](https://docs.letta.com/letta-code/channels#slack-cli). You need both the bot token (`xoxb-...`) and app-level token (`xapp-...`).
2. Set `SLACK_BOT_TOKEN` and `SLACK_APP_TOKEN` in your service's environment.
3. Redeploy. The server starts with `--channels slack`.
4. Bind the Slack app to an agent from the desktop app or via shell:

   ```bash
   letta channels bind --channel slack --agent <agent-id>
   ```

5. DM the app or `@mention` it in a channel.

### Rotating tokens or reconfiguring

Channel config is written once on first boot so that pairings, bindings, and allowlists survive restarts. To apply a new token, delete the file and redeploy:

```bash
rm ~/.letta/channels/telegram/accounts.json   # or slack/accounts.json
```

### Multiple accounts per channel

The env-var path only bootstraps a single account per channel. For multiple Telegram bots or Slack workspaces, either pre-write `~/.letta/channels/<channel>/accounts.json` manually with all accounts, or run `letta channels configure <channel>` from a shell on the service.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LETTA_API_KEY` | optional | Your Letta API key from [app.letta.com](https://app.letta.com). Developer plans only. If unset, the server uses OAuth device flow. Required for self-hosted deployments. |
| `ENV_NAME` | `cloud` | Name shown in the environment picker on chat.letta.com |
| `LETTA_BASE_URL` | `https://api.letta.com` | Override for self-hosted Letta servers. |
| `TELEGRAM_BOT_TOKEN` | — | Enables the Telegram channel on boot. |
| `TELEGRAM_DM_POLICY` | `pairing` | `pairing`, `allowlist`, or `open`. |
| `SLACK_BOT_TOKEN` | — | Slack bot user OAuth token (`xoxb-...`). Requires `SLACK_APP_TOKEN`. |
| `SLACK_APP_TOKEN` | — | Slack app-level token (`xapp-...`) with `connections:write`. |
| `SLACK_DM_POLICY` | `open` | `open` or `allowlist`. |

## Verify

1. Deploy using any method above
2. Open [chat.letta.com](https://chat.letta.com) or the [Letta Code](https://letta.com) desktop app
3. Select your remote environment from the picker (bottom left)
4. Send a message

## Docs

- [Remote environments](https://docs.letta.com/letta-code/remote)
- [Letta Code](https://docs.letta.com/letta-code)
