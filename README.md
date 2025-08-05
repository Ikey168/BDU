# bdu-website

Offizielle Website der Berlin Debating Union, implementiert mit Next.js, Cloudflare Pages, Workers und D1.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Overview

Welcome to the **Berlin Debating Union** official website repository.  
This project delivers a full-featured, responsive web platform for managing events, membership, and content, leveraging Next.js on Cloudflare Pages, serverless Workers, and D1.

## Features

- Responsive event calendar with registration  
- User authentication & membership management  
- CMS-driven articles and resource pages via MDX  
- Discussion forum for member interaction  
- Email notifications and calendar sync  
- Payment processing with Stripe & PayPal  

## Prerequisites

- Node.js ≥ 16.x  
- npm or Yarn  
- A GitHub account  
- A Cloudflare account with Pages, Workers, D1 & Access enabled  
- Stripe and Mailjet (or SendGrid) free-tier accounts for payment and email services  

## Installation

1. **Clone the repository**  
   ```bash
   git clone https://github.com/<your-org>/bdu-website.git
   cd bdu-website
   ```

2. **Install dependencies**

   ```bash
   cd frontend && npm install
   cd ../workers && npm install
   ```

3. **Configure environment variables**

   * Copy `.env.example` to `.env`
   * Fill in your Cloudflare, Stripe, and Mailjet credentials

4. **Run locally**

   ```bash
   # Start the Workers backend
   cd workers && npm run dev

   # Start the Next.js frontend
   cd ../frontend && npm run dev
   ```

## Configuration

1. **Cloudflare Wrangler**

   * Authenticate: `wrangler login`
   * Configure `wrangler.toml` with your `account_id` and `project_name`

2. **GitHub Actions Secrets**

   * Add the following in your repository’s Settings > Secrets:

     * `CF_ACCOUNT_ID`
     * `CF_API_TOKEN`
     * `CF_PROJECT_NAME`
     * `STRIPE_SECRET_KEY`
     * `STRIPE_WEBHOOK_SECRET`
     * `MAILJET_API_KEY`
     * `MAILJET_SECRET`

## Usage

* Frontend: `http://localhost:3000`
* API endpoints: `http://localhost:8787/api`
* Manage events, users, and content via the built-in MDX CMS
* Test payment flows using Stripe test keys

## Contributing

1. Fork the repository
2. Create a feature branch:

   ```bash
   git checkout -b feat/your-feature
   ```
3. Commit your changes:

   ```bash
   git commit -m "Add some feature"
   ```
4. Push to GitHub:

   ```bash
   git push origin feat/your-feature
   ```
5. Open a Pull Request against `main`

Please follow the existing code style and ensure all CI checks pass before requesting a review.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
