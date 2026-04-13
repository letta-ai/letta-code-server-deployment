import modal

app = modal.App.lookup("letta-remote", create_if_missing=True)

image = (
    modal.Image.debian_slim(python_version="3.12")
    .apt_install("curl")
    .run_commands(
        "curl -fsSL https://deb.nodesource.com/setup_20.x | bash -",
        "apt-get install -y nodejs",
        "npm install -g @letta-ai/letta-code",
    )
)

with modal.enable_output():
    sb = modal.Sandbox.create(
        "letta", "server", "--env-name", "modal", "--debug",
        app=app,
        image=image,
        name="letta-server",
        secrets=[modal.Secret.from_name("letta-secrets")],
        timeout=24 * 60 * 60,  # 24 hours (max)
    )

print(f"Sandbox running: {sb.object_id}")
sb.detach()
