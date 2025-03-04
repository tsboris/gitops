{{/*
Expand the name of the chart.
*/}}
{{- define "app-generator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app-generator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app-generator.labels" -}}
helm.sh/chart: {{ include "app-generator.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Load the external application list from the specified file and merge with inline applications
*/}}
{{- define "app-generator.loadApplications" -}}
{{- $applications := list -}}
{{- $globalNamespace := "" -}}
{{- $globalRepoURL := "" -}}

{{- /* Load applications from values file */ -}}
{{- if .Values.applications -}}
{{- $applications = .Values.applications -}}
{{- end -}}

{{- /* Load applications from external file if provided */ -}}
{{- $applicationsFile := .Values.configFile -}}
{{- if $applicationsFile -}}
  {{- if .Files.Glob $applicationsFile -}}
    {{- $appConfig := .Files.Get $applicationsFile | fromYaml -}}
    
    {{- /* Extract global settings */ -}}
    {{- if $appConfig.namespace -}}
      {{- $globalNamespace = $appConfig.namespace -}}
    {{- end -}}
    
    {{- if $appConfig.repoURL -}}
      {{- $globalRepoURL = $appConfig.repoURL -}}
    {{- end -}}
    
    {{- if $appConfig.applications -}}
      {{- $newApps := list -}}
      
      {{- /* Process each application and add global values when missing */ -}}
      {{- range $app := $appConfig.applications -}}
        {{- $processedApp := deepCopy $app -}}
        
        {{- /* Apply global namespace if not specified in the app */ -}}
        {{- if and $globalNamespace (not $processedApp.namespace) -}}
          {{- $_ := set $processedApp "namespace" $globalNamespace -}}
        {{- end -}}
        
        {{- /* Apply global repoURL if not specified in the app */ -}}
        {{- if and $globalRepoURL (not $processedApp.repoURL) -}}
          {{- $_ := set $processedApp "repoURL" $globalRepoURL -}}
        {{- end -}}
        
        {{- $newApps = append $newApps $processedApp -}}
      {{- end -}}
      
      {{- /* Merge with existing applications */ -}}
      {{- $applications = concat $applications $newApps -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- /* Return the combined applications list */ -}}
{{- if $applications -}}
{{- $applications | toYaml -}}
{{- else -}}
[]
{{- end -}}
{{- end -}}

{{/*
Render sync policy
*/}}
{{- define "app-generator.syncPolicy" -}}
{{- if . -}}
{{- toYaml . }}
{{- end -}}
{{- end -}} 