# https://github.com/opensearch-project/helm-charts/blob/main/charts/opensearch-dashboards/templates/deployment.yaml

resource "kubernetes_deployment_v1" "opensearch-dashboards" {
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
    replicas = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "opensearch-dashboards"
        release = "opensearch"
      }
    }

    template {
      metadata {
        labels = {
          app = "opensearch-dashboards"
          release = "opensearch"
        }
        annotations = {}
      }

      spec {
        security_context {}
        service_account_name = kubernetes_service_account_v1.opensearch-dashboard-service-account.metadata.0.name
        container {
          name = "dashboards"
          security_context {
            capabilities {
              drop = ["ALL"]
            }
            run_as_non_root = true
            run_as_user = 1000
          }
          image = "opensearchproject/opensearch-dashboards:2.14.0"
          image_pull_policy = "IfNotPresent"
          readiness_probe {
            tcp_socket {
              port = 5601
            }
            period_seconds = 20
            timeout_seconds = 5
            failure_threshold = 10
            success_threshold = 1
            initial_delay_seconds = 10
          }

          liveness_probe {
            tcp_socket {
              port = 5601
            }
            period_seconds = 20
            timeout_seconds = 5
            failure_threshold = 10
            success_threshold = 1
            initial_delay_seconds = 10 
          }
          startup_probe {
            failure_threshold = 20
            initial_delay_seconds = 10
            period_seconds = 10
            success_threshold = 1
            tcp_socket {
              port = 5601
            }
            timeout_seconds = 5
          }

          env {
            name = "OPENSEARCH_HOSTS"
            value = "https://opensearch-cluster-master:9200"
          }

          env {
            name = "SERVER_HOST"
            value = "0.0.0.0"
          }

          port {
            container_port = 5601
            name = "http"
            protocol = "TCP"
          }

          resources {
            requests = {
              cpu = "100m"
              memory = "512M"
            }
            limits = {
              cpu = "100m"
              memory = "512M"
            }
          }
        }
      }
    }
  }
}
