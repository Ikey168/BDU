# Cloudflare Deployment Setup Guide

This guide explains how to configure GitHub Actions for automatic deployment to Cloudflare Pages and Workers.

## Required GitHub Secrets

Navigate to your repository's **Settings > Secrets and variables > Actions** and add the following secrets:

### Core Cloudflare Credentials
```
CF_API_TOKEN          # Cloudflare API Token with necessary permissions
CF_ACCOUNT_ID         # Your Cloudflare Account ID
```

### Cloudflare Pages Configuration
```
CF_PAGES_PROJECT_NAME # Name of your Cloudflare Pages project (e.g., "bdu-website")
```

### Cloudflare D1 Database Configuration
```
CF_D1_DATABASE_NAME   # Name of your D1 database (e.g., "bdu-production")
```

## How to Obtain Cloudflare Credentials

### 1. Cloudflare API Token
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens)
2. Click "Create Token"
3. Use "Custom token" template
4. Configure permissions:
   - **Account**: `Cloudflare Workers:Edit`, `Account Settings:Read`
   - **Zone**: `Zone Settings:Read`, `Zone:Read` (if using custom domain)
   - **User**: `User Details:Read`
5. Add Account Resources: `Include - All accounts` or specific account
6. Add Zone Resources: `Include - All zones` or specific zones
7. Copy the generated token

### 2. Cloudflare Account ID
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select your account
3. Scroll down to find "Account ID" in the right sidebar
4. Copy the Account ID

### 3. Cloudflare Pages Project Name
1. Go to [Cloudflare Pages](https://dash.cloudflare.com/pages)
2. Create a new project or use existing project name
3. Use the project name as `CF_PAGES_PROJECT_NAME`

### 4. D1 Database Name
1. Go to [Cloudflare D1](https://dash.cloudflare.com/d1)
2. Create a new database or use existing database name
3. Use the database name as `CF_D1_DATABASE_NAME`

## Project Structure Requirements

### Frontend (Next.js)
Your `frontend/package.json` should include these scripts:
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "jest",
    "export": "next export"
  }
}
```

For static export (recommended for Cloudflare Pages), add to `frontend/next.config.js`:
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  trailingSlash: true,
  images: {
    unoptimized: true
  }
}

module.exports = nextConfig
```

### Workers
Your `workers/package.json` should include these scripts:
```json
{
  "scripts": {
    "dev": "wrangler dev",
    "deploy": "wrangler deploy",
    "lint": "eslint src/",
    "test": "vitest",
    "type-check": "tsc --noEmit"
  }
}
```

Your `workers/wrangler.toml` should be configured:
```toml
name = "bdu-api"
main = "src/index.ts"
compatibility_date = "2024-08-06"

[env.production]
name = "bdu-api-production"

[[env.production.d1_databases]]
binding = "DB"
database_name = "bdu-production"
database_id = "your-d1-database-id"

[[env.production.vars]]
ENVIRONMENT = "production"
```

## Deployment Workflow Behavior

### On Push to Main
1. **Quality Checks**: 
   - Lint frontend and workers code
   - Run tests for both applications
   - Build applications to verify they compile

2. **Deploy to Cloudflare**:
   - Deploy frontend to Cloudflare Pages
   - Run D1 database migrations
   - Deploy workers to Cloudflare Workers

3. **Notification**:
   - Success/failure notifications in workflow

### Manual Deployment
- Can be triggered manually via GitHub Actions tab
- Uses `workflow_dispatch` trigger

## Environment Configuration

### Development Environment
- Frontend: `npm run dev` (localhost:3000)
- Workers: `wrangler dev` (localhost:8787)
- D1: Local development database

### Production Environment
- Frontend: Deployed to Cloudflare Pages
- Workers: Deployed to Cloudflare Workers
- D1: Production database with migrations

## Troubleshooting

### Common Issues

**1. "API token insufficient permissions"**
- Ensure your CF_API_TOKEN has all required permissions
- Check Account and Zone resource restrictions

**2. "Database not found"**
- Verify CF_D1_DATABASE_NAME matches exactly
- Ensure database exists in your Cloudflare account

**3. "Pages project not found"**
- Verify CF_PAGES_PROJECT_NAME matches exactly
- Create the Pages project in Cloudflare dashboard first

**4. "Build directory not found"**
- Check that frontend builds to the correct output directory
- Adjust `directory` path in Pages deployment step

### Debug Commands
```bash
# Test Wrangler authentication
npx wrangler whoami

# List D1 databases
npx wrangler d1 list

# List Pages projects
npx wrangler pages project list

# Check Workers deployment
npx wrangler deploy --dry-run
```

## Security Best Practices

1. **Rotate API tokens regularly**
2. **Use environment-specific databases**
3. **Limit API token permissions to minimum required**
4. **Monitor deployment logs for sensitive data exposure**
5. **Use Cloudflare Access for additional security**

## Next Steps

1. Add the required secrets to your GitHub repository
2. Create Cloudflare Pages project and D1 database
3. Configure `wrangler.toml` with your specific settings
4. Test the deployment workflow
5. Set up custom domains and DNS if needed
