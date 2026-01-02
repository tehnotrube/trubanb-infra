{{/*
Expand the name of the chart.
*/}}
{{- define "accommodation-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "accommodation-service.fullname" -}}
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
{{- define "accommodation-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "accommodation-service.labels" -}}
helm.sh/chart: {{ include "accommodation-service.chart" . }}
{{ include "accommodation-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: trubanb
{{- end }}

{{/*
Selector labels
*/}}
{{- define "accommodation-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "accommodation-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Database host - use provided value or construct from release name
*/}}
{{- define "accommodation-service.databaseHost" -}}
{{- if .Values.database.host }}
{{- .Values.database.host }}
{{- else }}
{{- printf "%s-postgresql-accommodation" .Release.Name }}
{{- end }}
{{- end }}

{{/*
Database secret name - use provided value or construct from release name
*/}}
{{- define "accommodation-service.databaseSecret" -}}
{{- if .Values.database.existingSecret }}
{{- .Values.database.existingSecret }}
{{- else }}
{{- printf "%s-postgresql-accommodation" .Release.Name }}
{{- end }}
{{- end }}
