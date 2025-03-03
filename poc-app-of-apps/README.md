# App-of-Apps GitOps Pattern

This repository contains a GitOps configuration for deploying applications across multiple Kubernetes clusters using the ArgoCD "App-of-Apps" pattern.

## Architecture Overview

- **6 Kubernetes Clusters** across two application types:
  - **bf-app clusters (t2)**: t2d, t2t, and t2p
  - **dc-app clusters (t3)**: t3d, t3t, and t3p
  
- **14 Namespaces** across clusters:
  - **t2d cluster**: poc-d-dev, poc-d-integ (bf-app applications)
  - **t2t cluster**: poc-d-qa, poc-d-uat, poc-d-pt, poc-d-stress (bf-app applications)
  - **t2p cluster**: poc-d-prod (bf-app applications)
  - **t3d cluster**: poc-d-dev, poc-d-integ (dc-app applications)
  - **t3t cluster**: poc-d-qa, poc-d-uat, poc-d-pt, poc-d-stress (dc-app applications)
  - **t3p cluster**: poc-d-prod (dc-app applications)
  
- **Each cluster** has its own ArgoCD instance

## Repository Structure

```
poc-app-of-apps/
├── apps/                       # Application Helm charts
│   ├── bf-app-01/              # Helm chart for bf-app-01
│   ├── bf-app-02/              # Helm chart for bf-app-02
│   ├── dc-app-01/              # Helm chart for dc-app-01
│   └── dc-app-02/              # Helm chart for dc-app-02
│
├── environments/               # Environment-specific configurations
│   ├── poc-d-dev/              # Dev environment
│   │   ├── applications/       # Application manifests for dev
│   │   └── values/             # Values for apps in dev
│   ├── poc-d-integ/            # Integration environment
│   ├── poc-d-qa/               # QA environment
│   ├── poc-d-uat/              # UAT environment
│   ├── poc-d-pt/               # Performance Testing environment
│   ├── poc-d-stress/           # Stress Testing environment
│   └── poc-d-prod/             # Production environment
│
├── app-of-apps/                # Parent applications
│   ├── t2d/                    # T2D cluster parent apps (bf-app applications)
│   │   ├── poc-d-dev-env.yaml  # Parent app for dev environment
│   │   └── poc-d-integ-env.yaml # Parent app for integ environment
│   ├── t2t/                    # T2T cluster parent apps (bf-app applications)
│   │   ├── poc-d-qa-env.yaml   # Parent app for qa environment
│   │   ├── poc-d-uat-env.yaml  # Parent app for uat environment
│   │   ├── poc-d-pt-env.yaml   # Parent app for pt environment
│   │   └── poc-d-stress-env.yaml # Parent app for stress environment
│   ├── t2p/                    # T2P cluster parent app (bf-app applications)
│   │   └── poc-d-prod-env.yaml # Parent app for prod environment
│   ├── t3d/                    # T3D cluster parent apps (dc-app applications)
│   │   ├── poc-d-dev-env.yaml  # Parent app for dev environment
│   │   └── poc-d-integ-env.yaml # Parent app for integ environment
│   ├── t3t/                    # T3T cluster parent apps (dc-app applications)
│   │   ├── poc-d-qa-env.yaml   # Parent app for qa environment
│   │   ├── poc-d-uat-env.yaml  # Parent app for uat environment
│   │   ├── poc-d-pt-env.yaml   # Parent app for pt environment
│   │   └── poc-d-stress-env.yaml # Parent app for stress environment
│   └── t3p/                    # T3P cluster parent app (dc-app applications)
│       └── poc-d-prod-env.yaml # Parent app for prod environment
│
└── argocd/                     # ArgoCD ApplicationSet configurations
    ├── t2d-appset.yaml
    ├── t2t-appset.yaml
    ├── t2p-appset.yaml
    ├── t3d-appset.yaml
    ├── t3t-appset.yaml
    └── t3p-appset.yaml
```

## App-of-Apps Pattern

This repository uses the "App-of-Apps" pattern, where:

1. Each ArgoCD instance gets a single ApplicationSet that points to parent applications
2. Each parent application manages all applications for a specific environment
3. The actual application manifests are defined in each environment's applications directory

## Benefits of This Approach

- **Clear Environment Boundaries**: Each environment has its own parent application
- **Enhanced Filtering**: Applications have consistent labels (team, component, environment, app-type)
- **Simplified Promotion**: Copy application manifests between environment directories to promote
- **Environment-Level Control**: Pause/resume all applications in an environment at once

## Deployment Workflow

Applications progress through environments in the following order (same flow for both bf-app and dc-app):

1. **poc-d-dev** (t2d/t3d clusters) - Initial development
2. **poc-d-integ** (t2d/t3d clusters) - Integration testing
3. **poc-d-qa** (t2t/t3t clusters) - Quality assurance
4. **poc-d-uat** (t2t/t3t clusters) - User acceptance testing
5. **poc-d-pt** (t2t/t3t clusters) - Performance testing
6. **poc-d-stress** (t2t/t3t clusters) - Stress testing
7. **poc-d-prod** (t2p/t3p clusters) - Production deployment

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

The same approach applies to dc-app applications, using their respective application manifests and clusters. 