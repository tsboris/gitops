# App-of-Apps GitOps Pattern

This repository contains a GitOps configuration for deploying applications across multiple Kubernetes clusters using the ArgoCD "App-of-Apps" pattern.

## Architecture Overview

- **3 Kubernetes Clusters**: t2d, t2t, and t2p
- **5 Namespaces** across clusters:
  - **t2d cluster**: poc-d-dev, poc-d-integ
  - **t2t cluster**: poc-d-qa, poc-d-uat
  - **t2p cluster**: poc-d-prod
- **Each cluster** has its own ArgoCD instance

## Repository Structure

```
poc-app-of-apps/
├── apps/                       # Application Helm charts
│   ├── bf-app-01/              # Helm chart for bf-app-01
│   └── bf-app-02/              # Helm chart for bf-app-02
│
├── environments/               # Environment-specific configurations
│   ├── poc-d-dev/              # Dev environment
│   │   ├── applications/       # Application manifests for dev
│   │   └── values/             # Values for apps in dev
│   ├── poc-d-integ/            # Integration environment
│   ├── poc-d-qa/               # QA environment
│   ├── poc-d-uat/              # UAT environment
│   └── poc-d-prod/             # Production environment
│
├── app-of-apps/                # Parent applications
│   ├── t2d/                    # T2D cluster parent apps
│   │   ├── poc-d-dev-env.yaml  # Parent app for dev environment
│   │   └── poc-d-integ-env.yaml # Parent app for integ environment
│   ├── t2t/                    # T2T cluster parent apps
│   │   ├── poc-d-qa-env.yaml   # Parent app for qa environment
│   │   └── poc-d-uat-env.yaml  # Parent app for uat environment
│   └── t2p/                    # T2P cluster parent app
│       └── poc-d-prod-env.yaml # Parent app for prod environment
│
└── argocd/                     # ArgoCD ApplicationSet configurations
    ├── t2d-appset.yaml
    ├── t2t-appset.yaml
    └── t2p-appset.yaml
```

## App-of-Apps Pattern

This repository uses the "App-of-Apps" pattern, where:

1. Each ArgoCD instance gets a single ApplicationSet that points to parent applications
2. Each parent application manages all applications for a specific environment
3. The actual application manifests are defined in each environment's applications directory

## Benefits of This Approach

- **Clear Environment Boundaries**: Each environment has its own parent application
- **Enhanced Filtering**: Applications have consistent labels (team, component, environment)
- **Simplified Promotion**: Copy application manifests between environment directories to promote
- **Environment-Level Control**: Pause/resume all applications in an environment at once

## Deployment Workflow

Applications progress through environments in the following order:

1. **poc-d-dev** (t2d cluster) - Initial development
2. **poc-d-integ** (t2d cluster) - Integration testing
3. **poc-d-qa** (t2t cluster) - Quality assurance
4. **poc-d-uat** (t2t cluster) - User acceptance testing
5. **poc-d-prod** (t2p cluster) - Production deployment

## Managing Application Versions

To promote an application to the next environment:

1. Copy the application manifest from the current environment to the target environment
2. Update the image tag in the values file for the target environment
3. Commit and push the changes

For example, to promote bf-app-01 from dev to integration:

```bash
# 1. Copy the application manifest
cp environments/poc-d-dev/applications/bf-app-01.yaml environments/poc-d-integ/applications/

# 2. Update the image tag in environments/poc-d-integ/values/bf-app-01.yaml

# 3. Commit and push
git add environments/poc-d-integ/
git commit -m "Promote bf-app-01 to integration"
git push
```

ArgoCD will automatically detect the new application in the integration environment and deploy it. 