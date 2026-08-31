## Docker Setup (Task 5)

This project can be built and run with Docker Compose — no local
Node/Yarn installation required.

| File | What it is |
|---|---|
| [`Dockerfile`](./Dockerfile) | Multi-stage build for the app container: installs dependencies, runs as a non-root user, no exposed ports (the app syncs into the Twenty server rather than serving its own UI). |
| [`docker-compose.yml`](./docker-compose.yml) | Defines two services: `server` (the Twenty platform itself, `twentycrm/twenty-app-dev` image, port 2020) and `app` (this project's own code, built from the Dockerfile above, syncing into `server`). |
| [`.dockerignore`](./.dockerignore) | Excludes `node_modules`, `.git`, build artifacts, and `.env` files from the Docker build context. |
| [`DOCKER_TASK_DOCS.md`](./dockerpdf.pdf) | Full documentation: architecture explanation, design decisions, testing steps, and issues faced. |

### Quick start

```bash
docker compose build
docker compose up
```

Once both containers are running, open [http://localhost:2020](http://localhost:2020) — you should see the Twenty login page.

### Stopping

```bash
docker compose down
```

To also wipe stored workspace data:
```bash
docker compose down -v
```

### More detail

See [`DOCKER_TASK_DOCS.md`](./DOCKER_TASK_DOCS.md) for the full
explanation of each file, how everything was tested, and issues
encountered (including a pre-existing app bug found and fixed while
testing the Docker sync).
