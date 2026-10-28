# Minecraft 26.2 (Fabric) + playit.gg

Fabric Minecraft server that runs on GitHub Actions and is exposed through the
playit.gg tunnel agent.

## Public address

```
malls-citrus.tun.ply.gg:25565
```

This address is always the same; it only accepts connections while a workflow
run is active.

## Start the server

From the GitHub UI: **Actions → Run Minecraft Server → Run workflow**.

Or from a terminal with `gh` authenticated:

```bash
./start-server.sh              # 350 minutes, 4G heap (defaults)
./start-server.sh 60 4G        # 60 minutes, 4G heap
```

Equivalent raw command:

```bash
gh workflow run "Run Minecraft Server" \
  -f duration_minutes=120 -f memory=4G
```

Watch it:

```bash
gh run watch
```

## Stop the server

Cancel the running workflow (GitHub UI → **Cancel workflow**, or):

```bash
gh run cancel $(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
```

The server also stops automatically when `duration_minutes` elapses.

## Limits

- GitHub Actions jobs are capped at **6 hours**, so the server can't run longer
  than that per dispatch.
- The world is restored/saved with the Actions cache (kept ~7 days after the
  last run). Long gaps between runs can lose progress.
- Only run **one** agent at a time. Don't run `./playit` locally while a
  workflow run is active — both use the same secret and the tunnel will flap.

## Run locally instead

```bash
./playit-start.sh                 # starts the agent (prints a claim link if unclaimed)
java -Xmx4G -jar loader.jar nogui # start the server
```

## Layout

| Path | Purpose |
|---|---|
| `playit` | playit.gg daemon (playitd) |
| `playit-cli` | playit.gg CLI (status / claim / reset) |
| `playit-start.sh` | start the local agent |
| `start-server.sh` | dispatch the GitHub Actions run |
| `playit-data/playit.toml` | agent secret key |
| `.github/workflows/run-server.yml` | the CI pipeline |
| `mods/`, `config/` | Fabric mods and config for MC 26.2 |
| `world/` | default world (also cached in Actions) |

## Security note

`playit-data/playit.toml` contains the playit.gg agent secret and this
repository is **public**. Anyone who reads it can control the agent and its
tunnel. If that's not acceptable, run `playit-cli reset`, re-claim the agent,
and store the secret as a GitHub Actions secret instead of committing it.
