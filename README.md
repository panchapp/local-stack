<h1 align="center">Local Stack</h1>

<p align="center">
  <img src="./assets/Panchito.svg" alt="panchapp-logo" width="150" alt="Nest Logo" />
  <br>
  <br>
  <em>Docker development environment for PanchApp with</em>
  <br>
  <span style="color: #42b883;">🐘 PostgreSQL • 🚀 NestJS • 🛠️ pgAdmin</span>
  <br>
</p>

<hr>

## Environment Setup

Copy and customize environment variables:

```bash
cp env.example .env
```

### Container Control Variables

You can control which containers are mounted by setting these flags in your `.env` file:

| Variable                  | Default | Description                          |
| ------------------------- | ------- | ------------------------------------ |
| `MOUNT_POSTGRES_DATABASE` | `true`  | Mount PostgreSQL database container  |
| `MOUNT_CORE_SERVICE`      | `false` | Mount NestJS core application        |
| `MOUNT_PGADMIN`           | `true`  | Mount pgAdmin database management UI |

### Scripts

```bash
# Starts services (respects MOUNT_* flags in .env)
./start.sh
```

```bash
# Stops services (respects MOUNT_* flags in .env)
./stop.sh
```

The scripts automatically read your `.env` file and only start/stop the containers that are enabled by the `MOUNT_*` flags.

### Services

| Service    | Description        | Control Flag              |
| ---------- | ------------------ | ------------------------- |
| Core App   | NestJS backend API | `MOUNT_CORE_SERVICE`      |
| PostgreSQL | Database server    | `MOUNT_POSTGRES_DATABASE` |
| pgAdmin    | Database admin UI  | `MOUNT_PGADMIN`           |

> **Note:** Services are only started if their corresponding `MOUNT_*` flag is set to `true` in your `.env` file.

### Default Credentials

**Database:**

- Host: `localhost:5432`
- Database: `local`
- User: `panchapp_user`
- Password: `panchapp_password`

**pgAdmin:**

- Email: `admin@panchapp.com`
- Password: `admin123`

### Development

- NestJS app auto-reloads on file changes
- Database initialization scripts go in `init-db/`
- Logs are saved to `logs/` directory

### Common Commands

```bash
# View service status
docker-compose ps
```

```bash
# View logs
docker-compose logs -f core-app
```

```bash
# Restart service
docker-compose restart core-app
```

```bash
# Database access
docker-compose exec postgres psql -U panchapp_user -d local
```

```bash
# Clean up
docker-compose down -v
```

### Troubleshooting

- **Port conflicts:** Ensure ports 3000, 5432, and 8080 are available
- **Database issues:** Wait for health check to pass, check `docker-compose ps`
- **App not starting:** Check logs with `docker-compose logs core-app`
