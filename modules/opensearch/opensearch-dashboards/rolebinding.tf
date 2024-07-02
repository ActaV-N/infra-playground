# https://github.com/opensearch-project/helm-charts/blob/main/charts/opensearch-dashboards/templates/rolebinding.yaml

resource "kubernetes_role_binding_v1" "opensearch-dashboards-role-binding" {
  metadata {
    name = "opensearch-opensearch-dashboards-dashboards-rolebinding"
    labels = {
      "helm.sh/chart"="opensearch-dashboards-2.18.0"
      "app.kubernetes.io/name"="opensearch-dashboards"
      "app.kubernetes.io/instance"="opensearch"
      "app.kubernetes.io/version"="2.14.0"
      "app.kubernetes.io/managed-by"="Terraform"
    }
    namespace = var.namespace
  }

  role_ref {
    kind = "Role"
    name = kubernetes_service_account_v1.opensearch-dashboard-service-account.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account_v1.opensearch-dashboard-service-account.metadata.0.name
    namespace = kubernetes_service_account_v1.opensearch-dashboard-service-account.metadata.0.namespace
  }
}
