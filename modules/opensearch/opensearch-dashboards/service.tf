resource "kubernetes_service_v1" "opensearch-dashboard" {
  metadata {
    name = "opensearch-opensearch-dashboards"
    labels = {
      "helm.sh/chart"="opensearch-dashboards-2.18.0"
      "app.kubernetes.io/name"="opensearch-dashboards"
      "app.kubernetes.io/instance"="opensearch"
      "app.kubernetes.io/version"="2.14.0"
      "app.kubernetes.io/managed-by"="Terraform"
    }
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    port {
      port = 5601
      protocol = "TCP"
      name = "http"
      target_port = 5601
    }

    selector = {
      app = "opensearch-dashboards"
      release = "opensearch"
    }
  }
}
