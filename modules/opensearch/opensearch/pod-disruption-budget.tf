# https://github.com/opensearch-project/helm-charts/blob/main/charts/opensearch/templates/poddisruptionbudget.yaml

resource "kubernetes_pod_disruption_budget_v1" "opensearch-pdb" {
  metadata {
    name = "opensearch-cluster-master-pdb"
    labels = {
      "helm.sh/chart"="opensearch-2.20.0"
      "app.kubernetes.io/name"="opensearch"
      "app.kubernetes.io/instance"="opensearch"
      "app.kubernetes.io/version"="2.14.0"
      "app.kubernetes.io/managed-by"="Helm"
      "app.kubernetes.io/component"="opensearch-cluster-master"
    }
  }

  spec {
    max_unavailable = 1
    selector {
      match_labels = {
        "app.kubernetes.io/name"="opensearch"
        "app.kubernetes.io/instance"="opensearch"
      }
    }
  }
}
