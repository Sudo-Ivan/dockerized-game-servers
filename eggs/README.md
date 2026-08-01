# Pterodactyl eggs

Egg exports for the game servers in this repository.

## Status: alpha

These eggs have **not been fully tested** on Pterodactyl. Treat them as **alpha**: pulls, startup, ports, and a few games that need extra services (Stardew Valley, AzerothCore) may need manual fixes on your nodes.

If something breaks, include the game name, your Wings version, and relevant logs when you report it.

## Layout

Eggs are sorted into folders by category (minecraft, source, survival, and so on). nest.json lists every file.

## Import

1. Create a nest in the panel (for example Dockerized Game Servers).
2. Import each JSON from the category folders (Admin → Nests → Import Egg).
3. Make sure your Wings nodes can pull the Docker image for each egg (GHCR login if needed).

CLI example:

```bash
php artisan p:egg:import --json=/path/to/eggs/minecraft/vanilla.json --nest=<nest-id>
```

## Regenerate

Run generate.py to rebuild all eggs from the server catalog. Pass your own GHCR prefix if you publish images under a different owner.

```bash
python3 eggs/generate.py ghcr.io/your-owner/your-repo
```

## How they work

Each egg points at the same Docker images used by the compose files in this repo. Data lives under /home/container on the Pterodactyl side. The game downloads or updates its files on first start, like when you run compose locally.
