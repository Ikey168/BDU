/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['localhost'],
    unoptimized: true
  },
  // Enable static export for Cloudflare Pages
  output: 'export',
  trailingSlash: true,
  experimental: {
    optimizeCss: true
  }
}

module.exports = nextConfig
