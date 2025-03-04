# ArgoCD Application Generator Helm Chart

This Helm chart implements the ArgoCD Application of Applications pattern. It generates ArgoCD Applications based on either an external configuration file or directly from values provided to the chart.

## Overview

The chart creates ArgoCD Application resources from a list of application definitions. Applications can be defined in:

1. An external YAML configuration file referenced by `configFile`
2. Directly in the `applications` list in the values file
3. A combination of both (applications from both sources will be merged)

## Installation

```bash
# Install with external configuration file
helm install app-generator ./app-generator \
  --set configFile=path/to/config.yaml

# Install with direct application configuration
helm install app-generator ./app-generator \
  --values path/to/values.yaml
```

## Configuration

### External Configuration File

The external configuration file can have two formats:

#### Format 1: Application-specific settings

```yaml
applications:
  - name: app-name
    namespace: argocd
    repoURL: https://github.com/example/repo.git
    targetRevision: HEAD
    path: path/to/app
    # ... other application properties
```

#### Format 2: Global settings with applications list

```yaml
# Global settings applied to all applications
namespace: poc-d-dev
repoURL: https://github.com/example/repo.git

# List of applications
applications:
  - name: app-name-1
    targetRevision: HEAD
    path: path/to/app1
    # ... app-specific properties

  - name: app-name-2
    targetRevision: HEAD
    path: path/to/app2
    # ... app-specific properties
```

With Format 2, the global `namespace` and `repoURL` are applied to all applications that don't explicitly specify these values.

### Values File Options

The chart supports the following values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `configFile` | Path to external application config file | `""` |
| `applications` | List of application definitions | `[]` |
| `applicationDefaults` | Default values for all applications | See below |

#### Application Defaults

Default values to use for all applications if not specified:

```yaml
applicationDefaults:
  namespace: argocd
  project: default
  server: https://kubernetes.default.svc
  targetNamespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Application Definition

Each application can have the following properties:

| Property | Description | Required |
|----------|-------------|----------|
| `name` | Name of the application | Yes |
| `namespace` | Namespace for the Application resource | No |
| `repoURL` | Git repository URL | Yes |
| `targetRevision` | Git revision (tag, branch, commit) | No |
| `path` | Path within the Git repository | Yes (if `chart` not specified) |
| `chart` | Helm chart name | Yes (if `path` not specified) |
| `helm` | Helm specific configuration | No |
| `labels` | Additional labels for the Application | No |
| `annotations` | Annotations for the Application | No |
| `project` | ArgoCD project name | No |
| `syncPolicy` | Sync policy configuration | No |
| `ignoreDifferences` | Resources and fields to ignore during sync | No |
| `info` | Information displayed in the ArgoCD UI | No |

## Examples

### Example 1: Application-specific configuration

```yaml
applications:
  - name: bf-app-01
    namespace: argocd
    repoURL: https://github.com/example/repo.git
    targetRevision: HEAD
    path: gitops/apps/bf-app-01
    labels:
      app-type: bf-app
    annotations:
      argocd.argoproj.io/sync-wave: "1"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
```

### Example 2: Global configuration with simplified applications

```yaml
# Global configuration
namespace: poc-d-dev
repoURL: https://github.com/example/repo.git

# Applications list
applications:
  - name: bf-app-01
    targetRevision: HEAD
    path: gitops/apps/t2/bf-app-01
    labels:
      version: 1.0.0

  - name: bf-app-02
    targetRevision: HEAD
    path: gitops/apps/t2/bf-app-02
    labels:
      version: 2.0.0
```

## Testing

You can test the chart without installing it using:

```bash
./test-chart.sh
```

This will generate template outputs in the `output` directory for different configuration scenarios. 