# Branch Protection Rules Configuration

This document outlines the branch protection rules that should be configured for the BDU website repository to ensure code quality and security.

## Required Branch Protection Rules for `main` Branch

### 1. Require Pull Request Reviews
- **Minimum approving reviews**: 1
- **Dismiss stale reviews when new commits are pushed**: ✅ Enabled
- **Require review from code owners**: ✅ Enabled (see `.github/CODEOWNERS`)
- **Restrict pushes that create commits**: ✅ Enabled

### 2. Require Status Checks
- **Require branches to be up to date before merging**: ✅ Enabled
- **Required status checks**:
  - `frontend-checks` (Frontend linting, testing, and build)
  - `workers-checks` (Workers linting, testing, and type checking)
  - `security-checks` (Security vulnerability scanning)
  - `all-checks` (Meta-check ensuring all required checks pass)

### 3. Restrict Pushes and Deletions
- **Restrict pushes**: ✅ Enabled
- **Restrict force pushes**: ✅ Enabled
- **Allow deletions**: ❌ Disabled
- **Allow force pushes**: ❌ Disabled

### 4. Additional Settings
- **Require linear history**: ✅ Enabled (prevents merge commits)
- **Include administrators**: ✅ Enabled (rules apply to admins too)

## Code Owners Configuration

The `.github/CODEOWNERS` file defines ownership for critical paths:

- **Global**: @Ikey168 (fallback for all files)
- **Frontend paths** (`/frontend/`, `/frontend/pages/`): @Ikey168
- **Workers/API paths** (`/workers/`, `/workers/api/`): @Ikey168
- **Infrastructure files**: @Ikey168

## How to Apply These Settings

### Option 1: GitHub Web Interface
1. Go to repository Settings → Branches
2. Click "Add rule" or edit existing rule for `main`
3. Configure the settings as outlined above

### Option 2: GitHub CLI (if available)
```bash
# Enable branch protection for main
gh api repos/Ikey168/BDU/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["frontend-checks","workers-checks","security-checks","all-checks"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":true}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

### Option 3: Terraform (for Infrastructure as Code)
```hcl
resource "github_branch_protection" "main" {
  repository_id = "BDU"
  pattern       = "main"

  required_status_checks {
    strict = true
    contexts = [
      "frontend-checks",
      "workers-checks", 
      "security-checks",
      "all-checks"
    ]
  }

  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
  }

  enforce_admins         = true
  allows_deletions       = false
  allows_force_pushes    = false
  require_signed_commits = false
}
```

## Status Checks Provided by CI/CD

The GitHub Actions workflow (`.github/workflows/ci.yml`) provides the following status checks:

1. **frontend-checks**: Linting, testing, and building the Next.js frontend
2. **workers-checks**: Linting, testing, and type checking Cloudflare Workers
3. **security-checks**: Vulnerability scanning with Trivy
4. **all-checks**: Meta-check ensuring all other checks pass

## Benefits

These branch protection rules ensure:
- **Code Quality**: All code is reviewed and tested before merging
- **Security**: Vulnerability scans catch potential security issues
- **Ownership**: Critical paths require review from designated maintainers
- **History Integrity**: Prevents force pushes and accidental deletions
- **Consistency**: Standardized process for all contributions
