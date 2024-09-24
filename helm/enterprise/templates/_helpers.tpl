{{/*
Expand the name of the chart.
*/}}
{{- define "portkeyenterprise.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "portkeyenterprise.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "portkeyenterprise.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "portkeyenterprise.labels" -}}
helm.sh/chart: {{ include "portkeyenterprise.chart" . }}
{{ include "portkeyenterprise.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "portkeyenterprise.selectorLabels" -}}
app.kubernetes.io/name: {{ include "portkeyenterprise.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "portkeyenterprise.annotations" -}}
{{- with .Values.service.annotations }}
{{- toYaml .}}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "portkeyenterprise.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "portkeyenterprise.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "dataservice.serviceAccountName" -}}
{{- if .Values.dataservice.serviceAccount.create -}}
{{ default (printf "%s-%s" (include "portkeyenterprise.fullname" .) .Values.dataservice.name) .Values.dataservice.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
{{ default "default" .Values.dataservice.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Create the image pull credentials
*/}}
{{- define "imagePullSecret" }}
{{- with . }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}



{{/*
Common labels
*/}}
{{- define "redis.labels" -}}
helm.sh/chart: {{ include "portkeyenterprise.chart" . }}
{{ include "redis.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "redis.selectorLabels" -}}
app.kubernetes.io/name: redis
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Vault Annotations
*/}}
{{- define "portkeyenterprise.vaultAnnotations" -}}
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/agent-inject-secret-{{ .Chart.Name }}: {{ .Values.vaultConfig.secretPath | quote }}
vault.hashicorp.com/role: {{ .Values.vaultConfig.role | quote }}
{{- end }}

{{/*
Vault Environment Variables
*/}}
{{- define "portkeyenterprise.vaultEnv" -}}
{{- range $key, $value := .Values.environment.data }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Chart.Name }}
      key: {{ $key }}
{{- end }}
{{- end }}

{{/*
Common Environment Env
*/}}
{{- define "portkeyenterprise.commonEnv" -}}
{{- if .Values.environment.create }}
{{- range $key, $value := .Values.environment.data }}
  - name: {{ $key }}
    valueFrom:
      {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: {{ $key }}
{{- end }}
{{- end }}
{{- end }}