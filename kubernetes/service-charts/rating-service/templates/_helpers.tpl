{{/*
Expand the name of the chart.
*/}}
{{- define "rating-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "rating-service.fullname" -}}
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
{{- define "rating-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rating-service.labels" -}}
helm.sh/chart: {{ include "rating-service.chart" . }}
{{ include "rating-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: trubanb
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rating-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rating-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MongoDB host - use provided value or construct from release name
*/}}
{{- define "rating-service.mongodbHost" -}}
{{- if .Values.mongodb.host }}
{{- .Values.mongodb.host }}
{{- else }}
{{- printf "%s-mongodb" .Release.Name }}
{{- end }}
{{- end }}

{{/*
MongoDB secret name - use provided value or construct from release name
*/}}
{{- define "rating-service.mongodbSecret" -}}
{{- if .Values.mongodb.existingSecret }}
{{- .Values.mongodb.existingSecret }}
{{- else }}
{{- printf "%s-mongodb" .Release.Name }}
{{- end }}
{{- end }}
