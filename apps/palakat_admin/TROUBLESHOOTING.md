# Troubleshooting Guide - Palakat Admin

## Network Connection Errors

### Error: "The XMLHttpRequest onError callback was called"

This error typically occurs when the Flutter web app cannot connect to the backend API. Here are the solutions:

#### 1. Check if Backend is Running

Make sure the backend server is running:

```bash
# From project root
./scripts/backend-local.sh
```

Or manually:

```bash
cd apps/palakat_backend
pnpm run start:dev
```

The backend should be accessible at `http://localhost:3000` or `http://192.168.0.130:3000`

#### 2. Verify Backend Connectivity

Use the connectivity check script:

```bash
./scripts/check-backend.sh
```

Or manually test with curl:

```bash
curl http://localhost:3000/api/v1/auth/sign-in
```

#### 3. Update .env Configuration

**For local development (backend on same machine):**

```env
API_BASE_URL=http://localhost
API_BASE_PORT=3000
API_BASE_VERSION=api/v1
```

**For network development (backend on different machine):**

```env
API_BASE_URL=http://192.168.0.130
API_BASE_PORT=3000
API_BASE_VERSION=api/v1
```

Make sure the IP address matches your backend server's IP.

#### 4. CORS Issues

If the backend is running but you still get connection errors, it might be a CORS issue.

The backend should have CORS enabled in `apps/palakat_backend/src/main.ts`:

```typescript
app.enableCors({
  origin: '*',
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  credentials: true,
});
```

#### 5. Browser Security

Chrome and other browsers may block requests to local IP addresses. Try:

- Use `localhost` instead of `127.0.0.1` or IP addresses
- Check browser console for detailed error messages
- Disable browser extensions that might block requests
- Try in incognito mode

#### 6. Firewall/Network Issues

If using an IP address (not localhost):

- Make sure your firewall allows connections on port 3000
- Verify both machines are on the same network
- Try pinging the backend server: `ping 192.168.0.130`

## Common Solutions

### Quick Fix: Use Localhost

If the backend is on the same machine, update `.env`:

```bash
# Copy the local configuration
cp apps/palakat_admin/.env.local apps/palakat_admin/.env
```

Then restart the admin app:

```bash
./scripts/admin.sh --device chrome
```

### Verify Environment Variables

Check that your `.env` file has all required variables:

```bash
cat apps/palakat_admin/.env
```

Should contain:
- `API_BASE_URL`
- `API_BASE_PORT`
- `API_BASE_VERSION`

### Check Backend Logs

Look at the backend terminal for any error messages or CORS warnings.

### Test API Directly

Use curl or Postman to test the API endpoint:

```bash
curl -X POST http://localhost:3000/api/v1/auth/sign-in \
  -H "Content-Type: application/json" \
  -d '{"phone": "1234567890", "password": "test"}'
```

## Still Having Issues?

1. Check the browser console (F12) for detailed error messages
2. Verify the backend is running: `ps aux | grep nest`
3. Check if port 3000 is in use: `lsof -i :3000`
4. Try restarting both backend and admin app
5. Clear browser cache and reload

## Development Workflow

Recommended startup order:

1. Start backend: `./scripts/backend-local.sh`
2. Wait for backend to be ready (check logs)
3. Start admin app: `./scripts/admin.sh --device chrome`
4. Or use combined script: `./scripts/dev.sh --admin`
