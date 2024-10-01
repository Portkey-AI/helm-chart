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
{{- if .Values.useVaultInjection }}
  {{- include "portkeyenterprise.vaultEnv" .}}
{{- else }}
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
{{- end }}

{{/*
Common Environment Env as Map
*/}}
{{- define "portkeyenterprise.commonEnvMap" -}}
{{- $envMap := dict -}}
{{- if .Values.useVaultInjection }}
  {{- include "portkeyenterprise.vaultEnv" .}}
{{- end }}
{{- if .Values.environment.create }}
  {{- range $key, $value := .Values.environment.data }}
    {{- $_ := set $envMap $key $value -}}
  {{- end }}
{{- end }}
{{- toYaml $envMap -}}
{{- end }}

{{- define "logStore.commonEnv" -}}
{{- $allCommonEnv := include "portkeyenterprise.commonEnvMap" . | fromYaml -}}
- name: LOG_STORE
  valueFrom: {{ $allCommonEnv.LOG_STORE | quote  }}
- name: MONGO_DB_CONNECTION_URL
  value: {{ $allCommonEnv.MONGO_DB_CONNECTION_URL | quote }}
- name: MONGO_DATABASE
  value: {{ $allCommonEnv.MONGO_DATABASE | quote }}
- name: MONGO_COLLECTION_NAME
  value: {{ $allCommonEnv.MONGO_COLLECTION_NAME | quote }}
- name: MONGO_GENERATION_HOOKS_COLLECTION_NAME
  value: {{ $allCommonEnv.MONGO_GENERATION_HOOKS_COLLECTION_NAME | quote }}
- name: LOG_STORE_ACCESS_KEY
  value: {{ $allCommonEnv.LOG_STORE_ACCESS_KEY | quote }}
- name: LOG_STORE_SECRET_KEY
  value: {{ $allCommonEnv.LOG_STORE_SECRET_KEY | quote }}
- name: LOG_STORE_REGION
  value: {{ $allCommonEnv.LOG_STORE_REGION | quote }}
- name: LOG_STORE_GENERATIONS_BUCKET
  value: {{ $allCommonEnv.LOG_STORE_GENERATIONS_BUCKET | quote }}
- name: LOG_STORE_BASEPATH
  value: {{ $allCommonEnv.LOG_STORE_BASEPATH | quote }}
- name: LOG_STORE_AWS_ROLE_ARN
  value: {{ $allCommonEnv.LOG_STORE_AWS_ROLE_ARN | quote }}
- name: LOG_STORE_AWS_EXTERNAL_ID
  value: {{ $allCommonEnv.LOG_STORE_AWS_EXTERNAL_ID | quote }}
- name: AZURE_AUTH_MODE
  value: {{ $allCommonEnv.AZURE_AUTH_MODE | quote }}
- name: AZURE_STORAGE_ACCOUNT
  value: {{ $allCommonEnv.AZURE_STORAGE_ACCOUNT | quote }}
- name: AZURE_STORAGE_KEY
  value: {{ $allCommonEnv.AZURE_STORAGE_KEY | quote }}
- name: AZURE_STORAGE_CONTAINER
  value: {{ $allCommonEnv.AZURE_STORAGE_CONTAINER | quote }}
{{- end }}

{{- define "analyticStore.commonEnv" -}}
{{- $allCommonEnv := include "portkeyenterprise.commonEnvMap" . | fromYaml -}}
- name: ANALYTICS_STORE
  value: {{ $allCommonEnv.ANALYTICS_STORE | quote }}
- name: ANALYTICS_STORE_ENDPOINT
  value: {{ $allCommonEnv.ANALYTICS_STORE_ENDPOINT | quote }}
- name: ANALYTICS_STORE_USER
  value: {{ $allCommonEnv.ANALYTICS_STORE_USER | quote }}
- name: ANALYTICS_STORE_PASSWORD
  value: {{ $allCommonEnv.ANALYTICS_STORE_PASSWORD | quote }}
- name: ANALYTICS_LOG_TABLE
  value: {{ $allCommonEnv.ANALYTICS_LOG_TABLE | quote }}
- name: ANALYTICS_FEEDBACK_TABLE
  value: {{ $allCommonEnv.ANALYTICS_FEEDBACK_TABLE | quote }}
{{- end }}

{{- define "cacheStore.commonEnv" -}}
{{- $allCommonEnv := include "portkeyenterprise.commonEnvMap" . | fromYaml -}}
- name: CACHE_STORE
  value: {{ $allCommonEnv.CACHE_STORE | quote }}
- name: REDIS_URL
  value: {{ $allCommonEnv.REDIS_URL | quote }}
- name: REDIS_TLS_ENABLED
  value: {{ $allCommonEnv.REDIS_TLS_ENABLED | quote }}
- name: REDIS_MODE
  value: {{ $allCommonEnv.REDIS_MODE | quote }}
{{- end }}

{{- define "controlPlane.commonEnv" -}}
{{- $allCommonEnv := include "portkeyenterprise.commonEnvMap" . | fromYaml -}}
- name: PORTKEY_CLIENT_AUTH
  value: {{ $allCommonEnv.PORTKEY_CLIENT_AUTH | quote }}
- name: ORGANISATIONS_TO_SYNC
  value: {{ $allCommonEnv.ORGANISATIONS_TO_SYNC | quote }}
{{- end }}

# Data Service Env
{{- define "dataservice.commonEnv" -}}
{{- $allCommonEnv := include "portkeyenterprise.commonEnvMap" . | fromYaml -}}
- name: ALBUS_ENDPOINT
  value: "https://albus.portkey.ai"
- name: NODE_ENV
  value: "production"
- name: HYBRID_DEPLOYMENT
  value: "ON"
- name: CLICKHOUSE_HOST
  value: {{ $allCommonEnv.ANALYTICS_STORE_ENDPOINT | quote }}
- name: CLICKHOUSE_USER
  value: {{ $allCommonEnv.ANALYTICS_STORE_USER | quote }}
- name: CLICKHOUSE_PASSWORD
  value: {{ $allCommonEnv.ANALYTICS_STORE_PASSWORD | quote }}
- name: ANALYTICS_LOG_TABLE
  value: {{ $allCommonEnv.ANALYTICS_LOG_TABLE | quote }}
- name: FINETUNES_BUCKET
  value: {{ $allCommonEnv.FINETUNES_BUCKET | quote }}
- name: AWS_S3_FINETUNE_BUCKET
  value: {{ $allCommonEnv.FINETUNES_BUCKET | quote }}
- name: AWS_ROLE_ARN
  value: {{ $allCommonEnv.AWS_ROLE_ARN | quote }}
- name: LOG_EXPORTS_BUCKET
  value: {{ $allCommonEnv.LOG_EXPORTS_BUCKET | quote }}
{{- end }}