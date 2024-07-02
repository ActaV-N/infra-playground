# https://github.com/opensearch-project/helm-charts/blob/main/charts/opensearch-dashboards/templates/serviceaccount.yaml

resource "kubernetes_service_account_v1" "opensearch-dashboard-service-account" {
  metadata {
    name = "opensearch-opensearch-dashboards-dashboards"
    labels = {
      "helm.sh/chart"="opensearch-dashboards-2.18.0"
      "app.kubernetes.io/name"="opensearch-dashboards"
      "app.kubernetes.io/instance"="opensearch"
      "app.kubernetes.io/version"="2.14.0"
      "app.kubernetes.io/managed-by"="Terraform"
    }
    namespace = var.namespace
  }
}
