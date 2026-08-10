# Deploying with Coolify

The application is deployed from the repository's `Dockerfile`. Use a regular
Coolify application with the **Dockerfile** build pack rather than Docker
Compose so rolling deployments remain available.

## Application settings

- Dockerfile: `/Dockerfile`
- Exposed port: `3000`
- Port mappings: none
- Health check: `GET /up` on port `3000`, expected status `200`
- Pre-deployment command: `./bin/rails db:prepare`
- Start command: use the image default

## Required environment variables

| Variable | Value |
| --- | --- |
| `APP_HOST` | Public hostname without a scheme, for example `admin.example.com` |
| `DATABASE_URL` | Internal URL of the Coolify PostgreSQL resource |
| `RAILS_MASTER_KEY` | Contents of `config/master.key`; never commit this value |
| `RAILS_ENV` | `production` |

Recommended starting values for a small VPS are `RAILS_MAX_THREADS=3`,
`WEB_CONCURRENCY=1`, and `PORT=3000`. Increase concurrency only after checking
the application's memory usage and the PostgreSQL connection limit.

## PostgreSQL and backups

Create PostgreSQL as a separate Coolify resource and use its internal URL. Do
not expose the database publicly. Configure scheduled backups and copy them to
S3-compatible storage outside the VPS. Test restoring a backup before relying
on the deployment for production data.

## First deployment

1. Configure the domain, environment variables, and PostgreSQL resource.
2. Enable the `/up` health check and rolling deployments.
3. Deploy the application.
4. Verify the login flow and inspect the application logs.
5. Confirm that a backup can be created and restored.
