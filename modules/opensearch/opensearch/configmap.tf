# https://github.com/opensearch-project/helm-charts/blob/main/charts/opensearch/templates/configmap.yaml

resource "kubernetes_config_map_v1" "opensearch-config-map" {
  metadata {
    name = "opensearch-cluster-master-config"
    labels = {
      "helm.sh/chart"="opensearch-2.20.0"
      "app.kubernetes.io/name"="opensearch"
      "app.kubernetes.io/instance"="opensearch"
      "app.kubernetes.io/version"="2.14.0"
      "app.kubernetes.io/managed-by"="Terraform"
      "app.kubernetes.io/component"="opensearch-cluster-master"
    }
    namespace = var.namespace
  }
  data = {
    "opensearch.yml" = yamlencode({
      "cluster.name" = "opensearch-cluster"
      "network.host" = "0.0.0.0"
      "plugins" = {
        "security" = {
          "ssl" = {
            "transport" = {
              "pemcert_filepath"="esnode.pem"
              "pemkey_filepath"="esnode-key.pem"
              "pemtrustedcas_filepath"="root-ca.pem"
              "enforce_hostname_verification"=false
            }
            "http" = {
                "enabled"=true
                "pemcert_filepath"="esnode.pem"
                "pemkey_filepath"="esnode-key.pem"
                "pemtrustedcas_filepath"="root-ca.pem"
            }
          }
          "allow_unsafe_democertificates": true
          "allow_default_init_securityindex": true
          "authcz" = {
            "admin_dn" = ["CN=kirk,OU=client,O=client,L=test,C=de"]
          }
          "audit.type" = "internal_opensearch"
          "enable_snapshot_restore_privilege" = true
          "check_snapshot_restore_write_privileges" = true
          "restapi" = {
            "roles_enabled" = ["all_access", "security_rest_api_access"]
          }
          "system_indices" = {
            "enabled" = true
            "indices" = [
              ".opendistro-alerting-config",
              ".opendistro-alerting-alert*",
              ".opendistro-anomaly-results*",
              ".opendistro-anomaly-detector*",
              ".opendistro-anomaly-checkpoints",
              ".opendistro-anomaly-detection-state",
              ".opendistro-reports-*",
              ".opendistro-notifications-*",
              ".opendistro-notebooks",
              ".opendistro-asynchronous-search-response*",
            ]
          }
        }
      }
    })
  }
}
