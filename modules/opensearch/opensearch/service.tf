# https://github.com/opensearch-project/helm-charts/blob/main/charts/opensearch/templates/service.yaml

resource "kubernetes_service_v1" "opensearch-service" {
  metadata {
    name = "opensearch-cluster-master"
    labels = {
      "helm.sh/chart"="opensearch-2.20.0"
      "app.kubernetes.io/name"="opensearch"
      "app.kubernetes.io/instance"="opensearch"
      "app.kubernetes.io/version"="2.14.0"
      "app.kubernetes.io/managed-by"="Terraform"
      "app.kubernetes.io/component"="opensearch-cluster-master"
    }
    namespace = var.namespace
    annotations = {}
  }

  spec {
    type = "ClusterIP"
    selector = {
      "app.kubernetes.io/name"="opensearch"
      "app.kubernetes.io/instance"="opensearch"
    }
    port {
      name = "http"
      protocol = "TCP"
      port = 9200
    }

    port {
      name = "transport"
      protocol = "TCP"
      port = 9300    
    }
  }
}

resource "kubernetes_service_v1" "opensearch-service-headless" {
  metadata {
    name = "opensearch-cluster-master-headless"
    labels = {
      "helm.sh/chart"="opensearch-2.20.0"
      "app.kubernetes.io/name"="opensearch"
      "app.kubernetes.io/instance"="opensearch"
      "app.kubernetes.io/version"="2.14.0"
      "app.kubernetes.io/managed-by"="Terraform"
      "app.kubernetes.io/component"="opensearch-cluster-master"
    }
    annotations = {
      "service.alpha.kubernetes.io/tolerate-unready-endpoints"=true
    }
    namespace = var.namespace
  }

  spec {
    cluster_ip = "None"
    publish_not_ready_addresses = true
    selector = {
      "app.kubernetes.io/name"="opensearch"
      "app.kubernetes.io/instance"="opensearch"
    }
    port {
      name = "http"
      port = 9200
    }

    port {
      name = "transport"
      port = 9300
    }

    port {
      name = "metrics"
      port = 9600
    }
  }
}
