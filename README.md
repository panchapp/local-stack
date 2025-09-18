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

### Scripts

```bash
# Starts services
./start.sh
```

```bash
# Stops services
./stops.sh
```

### Services

| Service    | Description        |
| ---------- | ------------------ |
| Core App   | NestJS backend API |
| PostgreSQL | Database server    |
| pgAdmin    | Database admin UI  |

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
