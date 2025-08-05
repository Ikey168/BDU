README.md

Overview

Welcome to the Berlin Debating Union official website repository. This project delivers a full-featured, responsive web platform for managing events, membership, and content, leveraging Next.js on Cloudflare Pages, serverless Workers, and D1.

Table of Contents

Overview

Features

Prerequisites

Installation

Configuration

Usage

Contributing

License

Features

Responsive event calendar with registration

User authentication & membership management

CMS-driven articles and resource pages via MDX

Discussion forum for member interaction

Email notifications and calendar sync

Payment processing with Stripe & PayPal

Prerequisites

Node.js >= 16.x

npm or Yarn

A GitHub account

A Cloudflare account with Pages, Workers, D1 enabled

Stripe and Mailjet (or SendGrid) free-tier accounts for payment and email services

Installation

Clone the repository

git clone https://github.com/your-org/bdu-website.git
cd bdu-website

Install dependencies

cd frontend && npm install
cd ../workers && npm install

Configure environment variables

Copy .env.example to .env

Set your Cloudflare, Stripe, and Mailjet credentials

Run locally

# Start Workers backend
cd workers && npm run dev
# Start Next.js frontend
cd ../frontend && npm run dev

Configuration

Cloudflare Wrangler

Authenticate: wrangler login

Configure wrangler.toml with your account_id and project_name

GitHub Actions Secrets

Add CF_ACCOUNT_ID, CF_API_TOKEN, CF_PROJECT_NAME in repository settings

Add STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, MAILJET_API_KEY, MAILJET_SECRET

Usage

Visit http://localhost:3000 for the frontend

API endpoints available under http://localhost:8787/api

Create, update, and manage events via the CMS

Register and authenticate as a user; test payment flow with Stripe test keys

Contributing

Fork the repository

Create a feature branch: git checkout -b feat/your-feature

Commit your changes: git commit -m 'Add some feature'

Push to the branch: git push origin feat/your-feature

Open a Pull Request against main

Please follow the existing code style and ensure all CI checks pass before requesting a review.

License

This project is licensed under the MIT License. See LICENSE for details.
