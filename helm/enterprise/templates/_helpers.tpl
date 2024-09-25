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

{{- define "logStore.commonEnv" -}}
{{- if .Values.environment.create }}
- name: LOG_STORE
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: LOG_STORE
- name: MONGO_DB_CONNECTION_URL
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: MONGO_DB_CONNECTION_URL
- name: MONGO_DATABASE
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: MONGO_DATABASE
- name: MONGO_COLLECTION_NAME
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: MONGO_COLLECTION_NAME
- name: MONGO_GENERATION_HOOKS_COLLECTION_NAME
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: MONGO_GENERATION_HOOKS_COLLECTION_NAME
- name: LOG_STORE_ACCESS_KEY
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: LOG_STORE_ACCESS_KEY
- name: LOG_STORE_SECRET_KEY
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: LOG_STORE_SECRET_KEY
- name: LOG_STORE_REGION
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: LOG_STORE_REGION
- name: LOG_STORE_GENERATIONS_BUCKET
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: LOG_STORE_GENERATIONS_BUCKET
- name: LOG_STORE_BASEPATH
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: LOG_STORE_BASEPATH
- name: LOG_STORE_AWS_ROLE_ARN
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: LOG_STORE_AWS_ROLE_ARN
- name: LOG_STORE_AWS_EXTERNAL_ID
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: LOG_STORE_AWS_EXTERNAL_ID
- name: AZURE_AUTH_MODE
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: AZURE_AUTH_MODE
- name: AZURE_STORAGE_ACCOUNT
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: AZURE_STORAGE_ACCOUNT
- name: AZURE_STORAGE_KEY
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: AZURE_STORAGE_KEY
- name: AZURE_STORAGE_CONTAINER
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: AZURE_STORAGE_CONTAINER
{{- end }}
{{- end }}

{{- define "analyticStore.commonEnv" -}}
{{- if .Values.environment.create }}
- name: ANALYTICS_STORE
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: ANALYTICS_STORE
- name: ANALYTICS_STORE_ENDPOINT
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: ANALYTICS_STORE_ENDPOINT
- name: ANALYTICS_STORE_USER
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: ANALYTICS_STORE_USER
- name: ANALYTICS_STORE_PASSWORD
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: ANALYTICS_STORE_PASSWORD
- name: ANALYTICS_LOG_TABLE
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: ANALYTICS_LOG_TABLE
- name: ANALYTICS_FEEDBACK_TABLE
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: ANALYTICS_FEEDBACK_TABLE
{{- end }}
{{- end }}

{{- define "cacheStore.commonEnv" -}}
{{- if .Values.environment.create }}
- name: CACHE_STORE
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: CACHE_STORE
- name: REDIS_URL
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: REDIS_URL
- name: REDIS_TLS_ENABLED
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: REDIS_TLS_ENABLED
- name: REDIS_MODE
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: REDIS_MODE
{{- end }}
{{- end }}

{{- define "controlPlane.commonEnv" -}}
{{- if .Values.environment.create }}
- name: PORTKEY_CLIENT_AUTH
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: PORTKEY_CLIENT_AUTH
- name: ORGANISATIONS_TO_SYNC
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: ORGANISATIONS_TO_SYNC
{{- end }}
{{- end }}

# Data Service Env
{{- define "dataservice.commonEnv" -}}
- name: ALBUS_ENDPOINT
  value: "https://albus.portkey.ai"
- name: NODE_ENV
  value: "production"
- name: HYBRID_DEPLOYMENT
  value: "ON"
{{- if .Values.environment.create }}
- name: CLICKHOUSE_HOST
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: ANALYTICS_STORE_ENDPOINT
- name: CLICKHOUSE_USER
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: ANALYTICS_STORE_USER
- name: CLICKHOUSE_PASSWORD
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: ANALYTICS_STORE_PASSWORD
- name: ANALYTICS_LOG_TABLE
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: ANALYTICS_LOG_TABLE
- name: FINETUNES_BUCKET
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: FINETUNES_BUCKET
- name: LOG_EXPORTS_BUCKET
  valueFrom:
    {{- if $.Values.environment.secret }}
      secretKeyRef:
      {{- else }}
      configMapKeyRef:
      {{- end }}
        name: {{ include "portkeyenterprise.fullname" $ }}
        key: LOG_EXPORTS_BUCKET
{{- end }}
{{- end }}