# Palakat Backend Deployment Guide: AWS EC2 App + Supabase Database + CI/CD

## Purpose

This document is the recommended deployment plan for `apps/palakat_backend` using:

- **AWS EC2** for the **NestJS application runtime**
- **Supabase PostgreSQL** for the **database**
- **GitHub Actions** for **CI/CD**

It is tailored to the current codebase:

- `apps/palakat_backend` is a **NestJS** backend
- it uses **Prisma + PostgreSQL**
- it serves both **HTTP** and **Socket.IO/WebSocket** traffic on the same app port
- it can use a **Redis Socket.IO adapter**, but Redis is **not required** for a **single EC2 instance**
- it depends on several production environment variables, including Firebase and auth secrets

This guide assumes:

- **database hosting is moved out of AWS to Supabase**
- **AWS only runs the application server**
- you want a clean, step-by-step deployment flow with rollback and CI/CD

---

# 1. Recommended Architecture

Use this topology:

- **1 EC2 instance**
  - Ubuntu LTS
  - NestJS app runtime
  - Nginx reverse proxy
  - `systemd` service management
- **Supabase PostgreSQL**
  - managed Postgres database
- **GitHub Actions**
  - CI validation
  - CD over SSH to EC2
- **Optional domain + TLS**
  - domain from any DNS provider
  - Let's Encrypt certificate on EC2

## Why this architecture is a good fit

This is a strong middle ground:

- cheaper and simpler than full AWS managed database architecture
- safer than running PostgreSQL locally on the same EC2 instance
- good for a single backend instance
- easy to evolve later

## What this architecture intentionally does not use

This guide does **not** require:

- RDS PostgreSQL
- local PostgreSQL on EC2
- ElastiCache Redis
- Application Load Balancer
- Auto Scaling Group

Those are future upgrades, not day-one requirements.

---

# 2. Repo-Specific Facts That Affect Deployment

Before deploying, keep these repo-specific facts in mind:

- The backend package is located at `apps/palakat_backend`.
- The repo uses `pnpm`.
- Production startup command is `pnpm run start:prod`.
- Production-safe Prisma migration command is `pnpm run db:deploy`.
- The local helper `scripts/backend.sh` is for local/dev and is **not** the production deployment script.
- Prisma migrations already exist under `apps/palakat_backend/prisma/migrations`.
- The backend serves HTTP and Socket.IO on the same process and same port.
- Redis is optional in single-instance mode because the backend falls back to the in-memory Socket.IO adapter when Redis env is not configured.
- The backend exposes protected `GET /health` and `GET /health.json` routes for operational health snapshots.
- Those health routes are excluded from the global `api/v1` prefix, so the public paths are `/health` and `/health.json`, not `/api/v1/health`.
- Health responses require `HEALTH_PAGE_SECRET` and should be accessed with `x-health-secret`, `Authorization: Bearer <secret>`, or `?s=<secret>`.

---

# 3. Prerequisites

## 3.1 AWS prerequisites

You need:

- an AWS account
- permission to create EC2 and security groups
- an SSH key pair for EC2 access

## 3.2 Supabase prerequisites

You need:

- a Supabase account
- a Supabase project with PostgreSQL provisioned
- the external Postgres connection string from the Supabase dashboard
- the database password stored securely

## 3.3 GitHub prerequisites

You need:

- the Palakat repository hosted in GitHub
- permission to add GitHub Actions secrets
- a deployment branch policy, usually deploy only from `main`

## 3.4 Required backend environment variables

At minimum, production must define these correctly:

- `NODE_ENV=production`
- `PORT`
- `PUBLIC_BASE_URL`
- `HEALTH_PAGE_SECRET`
- `DATABASE_URL`
- `APP_CLIENT_USERNAME`
- `APP_CLIENT_PASSWORD`
- `JWT_SECRET`
- `PUSHER_BEAMS_INSTANCE_ID`
- `PUSHER_BEAMS_SECRET_KEY`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_STORAGE_BUCKET`
- `SONG_DB_FILE_ID`

Optional:

- `SONG_DB_CHURCH_ID`
- `REDIS_URL`
- `REDIS_HOST`
- `REDIS_PORT`

For the architecture in this guide, you will normally **leave Redis unset**.

---

# 4. Prepare Supabase

This is the first infrastructure step because the EC2 app depends on the database connection.

## 4.1 Create the Supabase project

In Supabase:

1. Create a new project.
2. Choose the region closest to your planned EC2 region.
3. Set a strong database password.
4. Wait until the database is ready.

## 4.2 Choose region carefully

Keep EC2 and Supabase geographically close.

Recommended rule:

- deploy EC2 in the same or nearest region to the Supabase region

This reduces:

- latency
- connection instability
- cross-region performance issues

## 4.3 Get the database connection string

From the Supabase dashboard, copy the **Postgres connection string** intended for external application access.

For this codebase, the main requirement is:

- set `DATABASE_URL` to the exact working Supabase PostgreSQL connection string

Important:

- use the connection string provided by Supabase
- ensure SSL is enabled if Supabase requires it
- if Supabase gives multiple connection options, start with the standard direct PostgreSQL connection string unless you have already validated a pooled option with Prisma in this codebase

## 4.4 Validate the database from your local machine first

Before setting up EC2, confirm the credentials actually work.

Example check:

```bash
psql "YOUR_SUPABASE_CONNECTION_STRING"
```

If that works, your database connection details are correct.

## 4.5 Database migrations strategy with Supabase

This repo already has Prisma migrations, so production should use:

```bash
pnpm run db:deploy
```

Do **not** use these in production:

- `pnpm run db:migrate`
- `pnpm run db:push`
- `prisma db push --force-reset`

---

# 5. Provision the EC2 Instance

## 5.1 Choose the AWS region first

Before creating the instance, choose the AWS region intentionally.

Recommended rule:

- pick the EC2 region closest to your Supabase project region

Why this matters:

- lower latency between NestJS and PostgreSQL
- fewer cross-region network problems
- better response time for every database-backed request

If your Supabase project is already live, choose the AWS region first, then keep the backend there unless you have a strong reason to move it later.

## 5.2 Open the EC2 launch flow in AWS Console

From AWS Console:

1. Open **EC2**.
2. Confirm the selected AWS region in the top-right corner.
3. Click **Launch instance**.

Use a clear instance name, for example:

- `palakat-backend-prod-01`

This makes later operations easier when you add more environments such as staging or a second production node.

## 5.3 Select the Amazon Machine Image and instance size

Recommended starting point:

- **Ubuntu Server 22.04 LTS** or **Ubuntu Server 24.04 LTS**
- `t2.micro`, `t3.micro`, `t3.small`, or `t3.medium`
- **20 GB gp3** root storage

Practical sizing guidance:

- use `t2.micro` or `t3.micro` for the cheapest first deployment
- use `t3.small` if you expect heavier runtime load, report generation, or more concurrent Socket.IO traffic
- use `t3.medium` only if you already expect a meaningfully higher production load

For most real production starts, `t3.small` is the safer default if the budget allows it.

## 5.4 Create or select the SSH key pair

In the **Key pair** section of the launch flow:

1. Choose an existing key pair, or click **Create new key pair**.
2. Use:
   - **Key pair type**: `ed25519` if your environment supports it cleanly, otherwise `RSA`
   - **Private key file format**: `.pem`
3. Download the key immediately and store it securely.

Important:

- do **not** commit the private key into the repository
- do **not** share it over chat or email
- if this is production, store it in your team secret manager or password vault

If you lose the key and have no alternate access path, SSH recovery becomes harder.

## 5.5 Configure network settings during instance launch

For this guide's single-instance architecture, the simplest AWS networking setup is usually enough:

- use the account's default VPC, or a dedicated VPC if your organization already standardizes on one
- place the instance in a **public subnet**
- enable **Auto-assign public IP**

In the AWS launch form, verify:

1. **VPC** is the intended VPC for this environment.
2. **Subnet** is a public subnet with internet reachability.
3. **Auto-assign public IP** is enabled.

Why this is appropriate here:

- you need SSH access for setup and CI/CD over SSH
- Nginx will accept public HTTP/HTTPS traffic
- the app itself will still be protected because only ports `80` and `443` are public

If your team already has a stricter network topology with bastion hosts, private subnets, or SSM-only access, you can adapt this later. For the deployment flow described in this guide, public-subnet EC2 is the straightforward path.

## 5.6 Configure the security group carefully

In the **Firewall (security groups)** section, either create a new security group or reuse a known-good one dedicated to this backend.

Recommended name:

- `palakat-backend-prod-sg`

Recommended inbound rules:

- **SSH** / TCP `22` / source = **your current public IP only**
- **HTTP** / TCP `80` / source = `0.0.0.0/0`
- **HTTPS** / TCP `443` / source = `0.0.0.0/0`

Do **not** expose publicly:

- `3000`
- `5432`
- `6379`

Why:

- `3000` is the internal NestJS app port and should only be reachable locally from Nginx
- `5432` is PostgreSQL and should not be hosted on this EC2 in this architecture
- `6379` is Redis and is not part of the day-one single-instance plan

Recommended outbound policy:

- keep the default **allow all outbound** rule at first

This is the simplest safe default because the server needs outbound access for things like:

- Supabase PostgreSQL
- package installs and OS updates
- Firebase services
- push notification integrations
- GitHub or other artifact sources during deployment

If you later restrict outbound rules, do it carefully and only after validating all required external destinations.

## 5.7 Review storage, monitoring, and launch details

Before clicking **Launch instance**, review these fields:

### Root volume

Recommended:

- **gp3**
- **20 GB** minimum

If you expect larger build artifacts, logs, or operational headroom, use:

- **30 GB** instead of 20 GB

### Delete on termination

For the root volume, leaving **Delete on termination = true** is fine for this architecture because the server should be replaceable and the primary application state lives outside the instance:

- database on Supabase
- deployment artifacts in Git

Important caveat:

- `/etc/palakat/palakat_backend.env` is still stored on the instance itself
- do **not** treat the EC2 copy of that env file as the only source of truth
- keep the canonical secret values in a secure team-controlled system such as a password vault or secret manager

Just make sure that env file and deployment steps are reproducible.

### Detailed monitoring

AWS basic monitoring is enough to start.

If you want earlier visibility into CPU or memory pressure, enable detailed monitoring later, but it is not required to complete the deployment in this guide.

### IAM role

You do **not** need a special IAM instance profile for the deployment plan in this guide.

Leave it empty unless you intentionally plan to integrate EC2 directly with:

- CloudWatch Agent
- SSM Session Manager
- S3 artifact delivery
- other AWS APIs from the application host

## 5.8 Launch the instance and record its identifiers

After you click **Launch instance**, record:

- **Instance ID**
- **Private IPv4 address**
- **Public IPv4 address**
- **Security group ID**
- **Availability Zone**

You will need at least the public IP immediately for SSH and initial Nginx verification.

## 5.9 Consider attaching an Elastic IP

If you plan to use the server for more than a quick test, allocate and associate an **Elastic IP**.

Why this helps:

- the public IP stays stable across stop/start cycles
- DNS setup is easier
- GitHub Actions and operational notes stay consistent

Without an Elastic IP, the instance public IP can change after stop/start events.

If you already have your final domain plan, using an Elastic IP is usually worth doing early.

## 5.10 Connect to the instance the first time

After launch, download or locate the `.pem` file on your local machine and protect it:

```bash
chmod 400 /path/to/your-key.pem
```

Then connect:

```bash
ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

For the Ubuntu AMI used in this guide, the default username is typically:

- `ubuntu`

If you choose a different AMI family, the SSH username may differ.

## 5.11 Update the machine

Immediately after first login:

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

This reduces the chance that you build the deployment on top of outdated base packages.

## 5.12 Install base packages

```bash
sudo apt-get install -y nginx git curl unzip build-essential ca-certificates gnupg lsb-release
```

These packages cover the needs of the rest of this guide:

- `nginx` for reverse proxy
- `git` and `curl` for deployment and system setup
- `unzip` for packaged artifacts
- `build-essential` for native dependency builds if needed
- certificate and repository helper packages for Node installation

## 5.13 Recommended immediate AWS-side hardening after launch

Once the instance is reachable and basic setup is confirmed, do these AWS-side checks:

1. Re-confirm port `22` is restricted to your own IP and not open to the world.
2. Add a clear **Name** tag if you did not do it during launch.
3. Verify the instance uses the intended security group.
4. If this is a long-lived environment, associate an Elastic IP.
5. Keep notes of the AWS region, VPC, subnet, security group, and public IP in your deployment runbook.

These are small steps, but they prevent many avoidable production mistakes.

---

# 6. Install Node.js and pnpm on EC2

## 6.1 Install Node.js 20

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## 6.2 Enable corepack and pnpm

```bash
sudo corepack enable
sudo corepack prepare pnpm@10.17.0 --activate
```

## 6.3 Verify installation

```bash
node -v
pnpm -v
```

---

# 7. Create the App User and Directory Layout

## 7.1 Create a dedicated app user

```bash
sudo adduser --disabled-password --gecos "" palakat
sudo usermod -aG www-data palakat
```

## 7.2 Create deployment directories

```bash
sudo mkdir -p /srv/palakat/backend/releases
sudo mkdir -p /srv/palakat/backend/shared
sudo mkdir -p /etc/palakat
sudo chown -R palakat:palakat /srv/palakat
sudo chown -R palakat:palakat /etc/palakat
```

Recommended layout:

```text
/srv/palakat/backend/
  releases/
  current -> /srv/palakat/backend/releases/<release_id>
/etc/palakat/
  palakat_backend.env
```

---

# 8. Create the Production Environment File

Store production secrets on EC2, not in the repository.

Create:

- `/etc/palakat/palakat_backend.env`

## 8.1 Example production env using Supabase

```env
NODE_ENV=production
PORT=3000
PUBLIC_BASE_URL=https://api.yourdomain.com
HEALTH_PAGE_SECRET=replace-with-a-long-random-secret

DATABASE_URL=postgresql://USERNAME:PASSWORD@HOST:PORT/postgres?sslmode=require

APP_CLIENT_USERNAME=replace-me
APP_CLIENT_PASSWORD=replace-me
JWT_SECRET=replace-with-a-long-random-secret

PUSHER_BEAMS_INSTANCE_ID=replace-me
PUSHER_BEAMS_SECRET_KEY=replace-me

FIREBASE_PROJECT_ID=replace-me
FIREBASE_CLIENT_EMAIL=replace-me
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_STORAGE_BUCKET=replace-me

SONG_DB_FILE_ID=replace-me
SONG_DB_CHURCH_ID=replace-me-if-used
```

If you do not have a domain yet, you can temporarily use:

```env
PUBLIC_BASE_URL=http://YOUR_EC2_PUBLIC_IP
```

Then update it later when TLS and domain are ready.

## 8.2 Protect the env file

```bash
sudo chown palakat:palakat /etc/palakat/palakat_backend.env
sudo chmod 600 /etc/palakat/palakat_backend.env
```

## 8.3 Important note about Supabase connection strings

Use the exact connection string format Supabase provides.

Do **not** guess or manually rewrite it unless necessary.

If Supabase provides a connection string with SSL requirements, keep those requirements intact.

## 8.4 Important note about the health route

The backend now exposes:

- `GET /health`
- `GET /health.json`

Both routes return the same structured operational snapshot and are intended for deployment verification and operations visibility.

Important:

- they are intentionally **outside** the `/api/v1` prefix
- they are intentionally **protected** by `HEALTH_PAGE_SECRET`
- they expose runtime and dependency state, so do **not** make them anonymously public

For operational checks, prefer sending the secret in the `x-health-secret` header.

---

# 9. Create the systemd Service

Create:

- `/etc/systemd/system/palakat-backend.service`

```ini
[Unit]
Description=Palakat Backend
After=network.target

[Service]
Type=simple
User=palakat
Group=palakat
WorkingDirectory=/srv/palakat/backend/current/apps/palakat_backend
EnvironmentFile=/etc/palakat/palakat_backend.env
Environment=PATH=/usr/local/bin:/usr/bin:/bin:/home/palakat/.local/share/pnpm
ExecStart=/usr/bin/env pnpm run start:prod
Restart=always
RestartSec=10
TimeoutStopSec=30
KillSignal=SIGINT
NoNewPrivileges=true
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

Enable it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable palakat-backend
```

---

# 10. Configure Nginx

Create:

- `/etc/nginx/sites-available/palakat-backend`

## 10.1 Nginx config for HTTP + WebSocket proxying

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    location /socket.io/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
    }

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
    }
}
```

If you are using only the EC2 public IP for now, you can temporarily use:

```nginx
server_name _;
```

## 10.2 Important note for reverse-proxy and load-balancer health checks

No special Nginx rule is required for `/health` because the existing `location /` block already proxies it to the NestJS app.

However, the backend health endpoint is protected. That means:

- `GET /health` without the secret will return `401 Unauthorized`
- any upstream health probe must be able to supply `HEALTH_PAGE_SECRET`
- if a future load balancer health checker cannot send the required secret, do not point it directly at the protected backend health route without first designing an internal-only alternative

For this single-EC2 architecture, the practical health signals are:

- `systemd` service status
- local or proxied `GET /health` checks that include `x-health-secret`
- logs from `journalctl` and Nginx

## 10.3 Enable Nginx site

```bash
sudo ln -s /etc/nginx/sites-available/palakat-backend /etc/nginx/sites-enabled/palakat-backend
sudo nginx -t
sudo systemctl restart nginx
```

## 10.4 Optional TLS with Let's Encrypt

If you have a domain pointing to EC2:

```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.yourdomain.com
```

---

# 11. Prepare SSH Access For CI/CD

## 11.1 Generate a deployment key locally

```bash
ssh-keygen -t ed25519 -C "palakat-backend-deploy" -f palakat_backend_deploy_key
```

This gives you:

- `palakat_backend_deploy_key`
- `palakat_backend_deploy_key.pub`

## 11.2 Install the public key on EC2

Append the `.pub` content to:

- `/home/palakat/.ssh/authorized_keys`

Then set permissions:

```bash
sudo -u palakat mkdir -p /home/palakat/.ssh
sudo -u palakat chmod 700 /home/palakat/.ssh
sudo -u palakat chmod 600 /home/palakat/.ssh/authorized_keys
```

## 11.3 Allow limited sudo for deployment

Create:

- `/etc/sudoers.d/palakat-deploy`

```text
palakat ALL=NOPASSWD: /bin/systemctl restart palakat-backend, /bin/systemctl status palakat-backend, /bin/systemctl is-active palakat-backend
```

Validate it:

```bash
sudo visudo -cf /etc/sudoers.d/palakat-deploy
```

---

# 12. Perform the First Manual Deployment

Do one manual deployment before automating GitHub Actions.

## 12.1 Copy the repo contents to the server

The release must include at least:

- `apps/palakat_backend/`
- `pnpm-lock.yaml`
- `pnpm-workspace.yaml`

## 12.2 Create the first release directory

```bash
sudo -u palakat mkdir -p /srv/palakat/backend/releases/initial
```

Place the files so the directory looks like:

```text
/srv/palakat/backend/releases/initial/
  apps/palakat_backend/
  pnpm-lock.yaml
  pnpm-workspace.yaml
```

## 12.3 Install dependencies and build

Run as `palakat` inside the release root:

```bash
cd /srv/palakat/backend/releases/initial
pnpm install --frozen-lockfile
pnpm --dir apps/palakat_backend run build
```

## 12.4 Attach the release to `current`

```bash
ln -sfn /srv/palakat/backend/releases/initial /srv/palakat/backend/current
```

## 12.5 Copy env and run production migrations against Supabase

```bash
cd /srv/palakat/backend/current/apps/palakat_backend
cp /etc/palakat/palakat_backend.env .env
pnpm run db:deploy
```

This command applies Prisma migrations to the **Supabase PostgreSQL** database.

## 12.6 Start the app service

```bash
sudo systemctl start palakat-backend
sudo systemctl status palakat-backend --no-pager
```

## 12.7 Verify the deployment

```bash
journalctl -u palakat-backend -n 100 --no-pager
ss -ltnp | grep 3000
curl -sS -H "x-health-secret: YOUR_HEALTH_PAGE_SECRET" http://127.0.0.1:3000/health
curl -sS -H "x-health-secret: YOUR_HEALTH_PAGE_SECRET" http://YOUR_EC2_PUBLIC_IP/health
```

If TLS and domain are ready:

```bash
curl -sS -H "x-health-secret: YOUR_HEALTH_PAGE_SECRET" https://api.yourdomain.com/health
```

The health response is JSON, not just headers. At minimum, confirm:

- the request does **not** return `401 Unauthorized`
- the response contains `overallStatus`
- `overallStatus` is `healthy` or a non-critical `degraded` state you understand

---

# 13. GitHub Actions Secrets

Add these repository secrets:

- `EC2_HOST`
- `EC2_PORT`
- `EC2_USER`
- `EC2_SSH_PRIVATE_KEY`

Recommended values:

- `EC2_HOST`: EC2 public IP or domain
- `EC2_PORT`: `22`
- `EC2_USER`: `palakat`
- `EC2_SSH_PRIVATE_KEY`: contents of `palakat_backend_deploy_key`

Keep the production app env file on EC2 at `/etc/palakat/palakat_backend.env`.

---

# 14. CI/CD Workflow Design

The deployment workflow should do this:

- trigger on push to `main`
- checkout code
- install Node and pnpm
- install dependencies
- build the backend in CI
- package a release artifact
- upload the artifact to EC2 over SSH
- extract into a new release directory
- install dependencies on EC2
- copy the server-side env file into the release
- build on EC2
- run Prisma `db:deploy` against Supabase
- switch the `current` symlink
- restart `systemd`
- verify service status
- verify the protected `/health` route using `HEALTH_PAGE_SECRET`

This gives you a repeatable deployment flow without storing database secrets in GitHub.

---

# 15. Sample GitHub Actions Workflow

Create this file later at:

- `.github/workflows/palakat-backend-deploy.yml`

```yaml
name: Deploy Palakat Backend

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Setup pnpm
        uses: pnpm/action-setup@v4
        with:
          version: 10.17.0

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Build backend
        run: pnpm --dir apps/palakat_backend run build

      - name: Package release artifact
        run: |
          RELEASE_DIR=palakat_backend_release
          mkdir -p "$RELEASE_DIR"
          cp -R apps "$RELEASE_DIR/"
          cp pnpm-lock.yaml "$RELEASE_DIR/"
          cp pnpm-workspace.yaml "$RELEASE_DIR/"
          tar -czf palakat_backend_release.tar.gz -C "$RELEASE_DIR" .

      - name: Upload artifact to EC2
        uses: appleboy/scp-action@v0.1.7
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_PRIVATE_KEY }}
          port: ${{ secrets.EC2_PORT }}
          source: "palakat_backend_release.tar.gz"
          target: "/tmp"

      - name: Deploy on EC2
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_PRIVATE_KEY }}
          port: ${{ secrets.EC2_PORT }}
          script_stop: true
          script: |
            set -euo pipefail
            RELEASE_ID=$(date +%Y%m%d%H%M%S)
            RELEASE_DIR=/srv/palakat/backend/releases/$RELEASE_ID
            mkdir -p "$RELEASE_DIR"
            tar -xzf /tmp/palakat_backend_release.tar.gz -C "$RELEASE_DIR"
            cd "$RELEASE_DIR"
            pnpm install --frozen-lockfile
            cp /etc/palakat/palakat_backend.env "$RELEASE_DIR/apps/palakat_backend/.env"
            pnpm --dir apps/palakat_backend run build
            cd "$RELEASE_DIR/apps/palakat_backend"
            pnpm run db:deploy
            ln -sfn "$RELEASE_DIR" /srv/palakat/backend/current
            sudo systemctl restart palakat-backend
            sudo systemctl is-active palakat-backend
            HEALTH_PAGE_SECRET=$(grep '^HEALTH_PAGE_SECRET=' /etc/palakat/palakat_backend.env | cut -d= -f2-)
            curl -fsS -H "x-health-secret: ${HEALTH_PAGE_SECRET}" http://127.0.0.1:3000/health > /dev/null
            rm -f /tmp/palakat_backend_release.tar.gz
```

---

# 16. Supabase-Specific Operational Notes

## 16.1 Keep EC2 and Supabase close geographically

This matters because every application query goes from EC2 to Supabase over the network.

Choose regions that minimize latency.

## 16.2 Use SSL requirements exactly as provided

If Supabase requires SSL in the connection string, preserve that requirement.

Do not strip SSL parameters.

## 16.3 Connection management

This codebase currently uses a standard Postgres connection string through `DATABASE_URL`.

Start simple:

- use the standard working Supabase database URL
- keep a single EC2 app instance first

If you later hit connection pressure or scaling issues, then evaluate whether Supabase pooling options and Prisma behavior should be tuned more deliberately.

## 16.4 Migrations against a managed database

Always treat schema changes more carefully when your production database is managed externally.

Recommended discipline:

- review migration SQL before deploy
- deploy schema changes during controlled windows
- take a backup/export before risky migrations

## 16.5 Backups

Supabase handles database operations, but backup and point-in-time recovery capabilities depend on your Supabase plan.

You should still understand:

- what your Supabase plan guarantees
- what restore options you actually have
- whether you want periodic manual export backups for extra safety

---

# 17. Rollback Procedure

## 17.1 Code rollback

List releases:

```bash
ls -1 /srv/palakat/backend/releases
readlink /srv/palakat/backend/current
```

Switch back to the previous good release:

```bash
ln -sfn /srv/palakat/backend/releases/<previous_release_id> /srv/palakat/backend/current
sudo systemctl restart palakat-backend
sudo systemctl status palakat-backend --no-pager
```

## 17.2 Database rollback caution

If the release applied a non-backward-compatible migration to Supabase, rolling back code alone may not be enough.

For that reason:

- review migrations before deployment
- keep database backup/restore options understood in advance
- avoid destructive migrations unless necessary

---

# 18. Security Checklist

Before go-live, make sure these are true.

## 18.1 EC2 security

- SSH restricted to your IP only
- app port `3000` not publicly exposed
- OS packages kept updated
- only Nginx exposed publicly

## 18.2 Secret handling

- production `.env` stored only on EC2
- `/etc/palakat/palakat_backend.env` permission set to `600`
- strong random values used for `JWT_SECRET`, `APP_CLIENT_USERNAME`, and `APP_CLIENT_PASSWORD`
- Firebase private key stored only in protected server env

## 18.3 Database access

- use the exact Supabase credentials provided
- do not hardcode DB secrets into the repository
- if your Supabase plan supports network restrictions and you want stronger hardening, restrict access appropriately after confirming EC2 egress behavior

---

# 19. What Not To Do

Avoid these mistakes:

- do not install PostgreSQL on EC2 if Supabase is the chosen database platform
- do not use `prisma migrate dev` in production
- do not use `prisma db push --force-reset` in production
- do not expose port `3000` publicly
- do not store the production `.env` file in Git
- do not add Redis unless you are actually moving beyond a single app instance or a more complex ingress topology
- do not assume Supabase backup guarantees without checking your actual plan

---

# 20. Exact Rollout Order

Follow this order:

1. Create the Supabase project.
2. Copy and validate the Supabase Postgres connection string.
3. Launch the EC2 instance.
4. Configure the EC2 security group.
5. SSH into EC2 and update packages.
6. Install Node.js, pnpm, and Nginx.
7. Create the `palakat` user and deployment directories.
8. Create `/etc/palakat/palakat_backend.env` using the Supabase connection string.
9. Create the `systemd` service.
10. Configure Nginx.
11. Perform one manual deployment.
12. Run `pnpm run db:deploy` against Supabase.
13. Verify logs and the protected `/health` response.
14. Add GitHub Actions secrets.
15. Add the deployment workflow.
16. Push a controlled change to `main` and verify full CI/CD.
17. Add TLS once the domain is ready.

---

# 21. Future Upgrades

Move beyond this architecture when one of these becomes true:

- you need multiple EC2 app instances
- you need a load balancer
- you need stronger Socket.IO coordination across instances
- you need stricter infrastructure isolation
- you need higher deployment safety and uptime guarantees

Natural upgrade path:

- single EC2 -> multiple EC2 instances
- direct EC2 ingress -> ALB
- in-memory Socket.IO adapter -> Redis-backed adapter
- basic deployment -> blue/green or canary deployment

When you eventually introduce an ALB, explicitly re-evaluate health-check design because the backend `/health` route is protected by `HEALTH_PAGE_SECRET`.

The database can remain on Supabase if it continues to meet your requirements.

---

# Summary

If you want Palakat backend to use **Supabase for PostgreSQL** and **AWS only for running the NestJS app**, the recommended plan is:

- **Supabase PostgreSQL** as the managed database
- **one EC2 instance** for the NestJS backend
- **Nginx + systemd** on EC2
- **GitHub Actions** for CI/CD over SSH
- **Prisma `db:deploy`** for production migrations
- **no local PostgreSQL on EC2**
- **no Redis unless you later scale beyond one instance**

This gives you a clean, maintainable, and production-appropriate deployment model for `palakat_backend` with clear separation between app hosting and database hosting.

---

# 22. Post-Deployment Verification Checklist

After the first successful deployment, verify the runtime from several angles instead of relying on only one green signal.

## 22.1 Verify the service process

On EC2:

```bash
sudo systemctl status palakat-backend --no-pager
sudo systemctl is-active palakat-backend
journalctl -u palakat-backend -n 100 --no-pager
```

You want to confirm:

- the service is `active (running)`
- the process restarted cleanly after deployment
- there are no startup crashes related to env parsing, Prisma, or Firebase initialization

## 22.2 Verify the app is listening locally

```bash
ss -ltnp | grep 3000
curl -sS -H "x-health-secret: YOUR_HEALTH_PAGE_SECRET" http://127.0.0.1:3000/health
```

If the app is healthy behind Nginx, the local port should be listening before you test the public endpoint.

Remember:

- the path is `/health`, not `/api/v1/health`
- `/health.json` is also available and returns the same payload
- the route requires `HEALTH_PAGE_SECRET`

## 22.3 Verify public ingress through Nginx

Without TLS yet:

```bash
curl -sS -H "x-health-secret: YOUR_HEALTH_PAGE_SECRET" http://YOUR_EC2_PUBLIC_IP/health
```

With domain and TLS:

```bash
curl -sS -H "x-health-secret: YOUR_HEALTH_PAGE_SECRET" https://api.yourdomain.com/health
```

This confirms:

- Nginx is reachable
- Nginx can proxy traffic to the NestJS process
- DNS and TLS are working if enabled
- the protected health route is reachable end-to-end

## 22.4 Verify Prisma migration state

From the current release:

```bash
cd /srv/palakat/backend/current/apps/palakat_backend
cp /etc/palakat/palakat_backend.env .env
pnpm exec prisma migrate status
```

This helps confirm that the deployed app and the Supabase schema are aligned after `pnpm run db:deploy`.

## 22.5 Verify important environment-dependent features

For this codebase, a deployment is not fully validated until you confirm the environment-dependent integrations that matter most:

- authentication still works with the configured `JWT_SECRET`
- any document or report URL generation works with `PUBLIC_BASE_URL`
- Firebase-dependent flows initialize correctly with `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, and `FIREBASE_PRIVATE_KEY`
- push notification paths do not fail unexpectedly if `PUSHER_BEAMS_INSTANCE_ID` and `PUSHER_BEAMS_SECRET_KEY` are required in your production usage

## 22.6 Verify Redis behavior intentionally

For a single-instance EC2 deployment, Redis is optional.

That means:

- if `REDIS_URL`, `REDIS_HOST`, and `REDIS_PORT` are unset, the app should continue in single-instance mode
- a warning about Redis not being configured is not automatically a deployment failure in this architecture

Only treat Redis warnings as blocking if you intentionally decided to use a Redis-backed Socket.IO adapter.

---

# 23. Troubleshooting Guide

Use this section when the deployment completes but the app is not actually healthy.

## 23.1 `systemd` service fails immediately

Check:

```bash
sudo systemctl status palakat-backend --no-pager
journalctl -u palakat-backend -n 200 --no-pager
```

Common causes:

- the `current` symlink points to the wrong release
- the backend was not built successfully
- the env file is missing or unreadable
- the process cannot find `pnpm`

If the error mentions the startup target, remember the production script is:

```bash
pnpm run start:prod
```

And in this repo that resolves to:

```bash
prisma generate && node dist/src/main.js
```

So a broken deployment often means the release is missing `dist/` or failed before build finished.

## 23.2 Prisma cannot connect to Supabase

Symptoms usually look like:

- startup failure during Prisma initialization
- `db:deploy` failure
- connection timeout or authentication failure in logs

Check:

- `DATABASE_URL` is the exact Supabase external connection string
- the password is correct
- SSL parameters required by Supabase were preserved
- EC2 has outbound internet access
- the Supabase project is not paused or otherwise unavailable

From the server:

```bash
cd /srv/palakat/backend/current/apps/palakat_backend
cp /etc/palakat/palakat_backend.env .env
pnpm exec prisma migrate status
```

If the connection string was copied manually, re-copy it from Supabase instead of trying to hand-edit it.

## 23.3 Firebase Admin initialization fails

This repo reads:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`

The most common production mistake is malformed private key formatting.

Use the env file format shown earlier:

```env
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

If line breaks are pasted incorrectly, startup may fail even though the key content itself is correct.

## 23.4 `PUBLIC_BASE_URL` causes runtime errors

This backend uses `PUBLIC_BASE_URL` when generating document or report URLs.

If logs show errors like:

- `PUBLIC_BASE_URL is invalid`

Then fix the env value so it is a valid absolute base URL, for example:

```env
PUBLIC_BASE_URL=https://api.yourdomain.com
```

or temporarily:

```env
PUBLIC_BASE_URL=http://YOUR_EC2_PUBLIC_IP
```

Do not leave trailing mistakes such as malformed schemes or accidental spaces.

## 23.5 `/health` returns `401 Unauthorized` or `404 Not Found`

If your health check fails unexpectedly:

- confirm you are calling `/health` or `/health.json`, not `/api/v1/health`
- confirm `HEALTH_PAGE_SECRET` is present in `/etc/palakat/palakat_backend.env`
- confirm you are sending the same secret in `x-health-secret`, `Authorization: Bearer <secret>`, or `?s=<secret>`
- confirm Nginx is proxying to the current backend release

Useful checks:

```bash
grep '^HEALTH_PAGE_SECRET=' /etc/palakat/palakat_backend.env
curl -sS -H "x-health-secret: YOUR_HEALTH_PAGE_SECRET" http://127.0.0.1:3000/health
curl -sS -H "x-health-secret: YOUR_HEALTH_PAGE_SECRET" http://YOUR_EC2_PUBLIC_IP/health
```

A `401` usually means the secret is missing or wrong.

A `404` usually means the wrong path is being used or traffic is not reaching the current NestJS process.

## 23.6 Nginx works but WebSocket traffic is broken

If ordinary HTTP requests work but Socket.IO features do not:

- confirm the `/socket.io/` Nginx location exists
- confirm the `Upgrade` and `Connection` headers are set
- confirm the backend is reachable on `127.0.0.1:3000`
- inspect Nginx logs

Useful checks:

```bash
sudo nginx -t
sudo systemctl status nginx --no-pager
sudo tail -n 100 /var/log/nginx/error.log
```

## 23.7 The workflow uploads successfully but the app does not update

Check these in order:

- the new release directory was actually created
- the artifact extracted into the expected path
- the `current` symlink now points to the new release
- `pnpm install` and `pnpm --dir apps/palakat_backend run build` completed successfully on EC2
- `sudo systemctl restart palakat-backend` actually ran and succeeded

Useful checks:

```bash
readlink /srv/palakat/backend/current
ls -la /srv/palakat/backend/releases
sudo systemctl status palakat-backend --no-pager
```

## 23.8 Redis warnings appear in logs

In this guide's architecture, Redis is optional.

If you did not configure any Redis env vars, a Redis-related warning can be acceptable as long as:

- the app starts normally
- HTTP works
- Socket.IO works for the single running instance

Do not add Redis just to silence a non-blocking warning unless you are actually moving to multi-instance requirements.

## 23.9 Deployment rollback after a bad release

If the new release is bad but the database migration was safe or backward-compatible:

```bash
ln -sfn /srv/palakat/backend/releases/<previous_release_id> /srv/palakat/backend/current
sudo systemctl restart palakat-backend
sudo systemctl status palakat-backend --no-pager
```

If the bad release also applied a destructive or incompatible schema migration to Supabase, stop and evaluate database recovery separately before assuming a code-only rollback is enough.
