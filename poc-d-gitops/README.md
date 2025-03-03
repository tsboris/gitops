# GitOps Multi-Cluster Deployment

This repository contains the GitOps configuration for deploying applications across multiple Kubernetes clusters and namespaces.

## Architecture Overview

- **3 Kubernetes Clusters**: dev, test, and prod
- **5 Namespaces** across clusters:
  - **dev cluster**: poc-d-dev, poc-d-integ
  - **test cluster**: poc-d-qa, poc-d-uat
  - **prod cluster**: poc-d-prod
- **Each cluster** has its own ArgoCD instance

## Repository Structure

```
gitops/poc-d-gitops/
├── apps/                  # Application Helm charts
│   └── t2/
│       ├── bf-app-01/     # Helm chart for bf-app-01
│       └── bf-app-02/     # Helm chart for bf-app-02
├── env/                   # Environment-specific values
│   ├── poc-d-dev/
│   ├── poc-d-integ/
│   ├── poc-d-qa/
│   ├── poc-d-uat/
│   └── poc-d-prod/
└── argocd/                # ArgoCD ApplicationSet configurations
    ├── dev-cluster-applicationset.yaml
    ├── test-cluster-applicationset.yaml
    └── prod-cluster-applicationset.yaml
```

## Deployment Workflow

Applications progress through environments in the following order:

1. **poc-d-dev** (dev cluster) - Initial development
2. **poc-d-integ** (dev cluster) - Integration testing
3. **poc-d-qa** (test cluster) - Quality assurance
4. **poc-d-uat** (test cluster) - User acceptance testing
5. **poc-d-prod** (prod cluster) - Production deployment

## Managing Application Versions

Each environment has its own values.yaml file that specifies:
- The namespace for deployment
- Application-specific image tags

To promote an application to the next environment:

1. Build and push a new application image with the appropriate tag
2. Update the image tag in the target environment's values.yaml file
3. Commit and push the changes to the Git repository
4. ArgoCD will automatically deploy the new version to the specified environment

## ArgoCD Configuration

Each cluster's ArgoCD instance is configured with an ApplicationSet that:
- Automatically discovers applications in the apps/t2/ directory
- Deploys each application to the appropriate namespaces
- Uses the environment-specific values files for configuration

## Example: Promoting bf-app-01

To promote bf-app-01 from development to integration:

1. Update the image tag in `env/poc-d-integ/values.yaml`:
   ```yaml
   bf-app-01:
     image:
       tag: "new-version-tag"
   ```

2. Commit and push the changes
3. ArgoCD will deploy the new version to the poc-d-integ namespace in the dev cluster

The same process applies for promoting to QA, UAT, and production environments. 