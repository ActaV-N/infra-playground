resource "kubernetes_stateful_set_v1" "opensearch" {
  metadata {
    name = "opensearch-cluster-master"
    labels = {
      "helm.sh/chart" = "opensearch-2.20.0"
      "app.kubernetes.io/name" = "opensearch"
      "app.kubernetes.io/instance" = "opensearch"
      "app.kubernetes.io/version" = "2.14.0"
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/component" = "opensearch-cluster-master"
    }
    annotations = {
      majorVersion = "2"
    }
    namespace = var.namespace
  }

  spec {
    service_name = "opensearch-cluster-master-headless"
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "opensearch"
        "app.kubernetes.io/instance" = "opensearch"
      }
    }

    replicas = 3

    pod_management_policy = "Parallel"

    update_strategy {
      type = "RollingUpdate"
    }

    volume_claim_template {
      metadata {
        name = "opensearch-cluster-master"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "8Gi"
          }
        }
        storage_class_name = ""
      }
    }

    template {
      metadata {
        name = "opensearch-cluster-master"
        labels = {
          "helm.sh/chart" = "opensearch-2.20.0"
          "app.kubernetes.io/name" = "opensearch"
          "app.kubernetes.io/instance" = "opensearch"
          "app.kubernetes.io/version" = "2.14.0"
          "app.kubernetes.io/managed-by" = "Terraform"
          "app.kubernetes.io/component" = "opensearch-cluster-master"
        }
        annotations = {}
      }
      spec {
        security_context {
          fs_group = 1000
          run_as_user = 1000
        }
        automount_service_account_token = false
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 1
              pod_affinity_term {
                topology_key = "kubernetes.io/hostname"
                label_selector {
                  match_expressions {
                    key      = "app.kubernetes.io/instance"
                    operator = "In"
                    values   = ["opensearch"]
                  }
                  match_expressions {
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = ["opensearch"]
                  }
                }
              }
            }
          }
        }

        termination_grace_period_seconds = 120

        volume {
          name = "config"
          config_map {
            name = "opensearch-cluster-master-config"
          }
        }

        volume {
          empty_dir {}
          name = "config-emptydir"
        }

        enable_service_links = true

        init_container {
          name              = "fsgroup-volume"
          image             = "busybox:latest"
          image_pull_policy = "IfNotPresent"
          command           = ["sh", "-c"]
          args              = ["chown -R 1000:1000 /usr/share/opensearch/data"]
          security_context {
            run_as_user = 0
          }
          resources {}
          volume_mount {
            name       = "opensearch-cluster-master"
            mount_path = "/usr/share/opensearch/data"
          }
        }

        init_container {
          name              = "configfile"
          image             = "opensearchproject/opensearch:2.14.0"
          image_pull_policy = "IfNotPresent"
          command           = ["sh", "-c", <<EOF
#!/usr/bin/env bash
cp -r /tmp/configfolder/*  /tmp/config/
            EOF
          ]
          
          resources {}
          volume_mount {
            name       = "config-emptydir"
            mount_path = "/tmp/config/"
          }

          volume_mount {
            name       = "config"
            mount_path = "/tmp/configfolder/opensearch.yml"
            sub_path   = "opensearch.yml"
          }
        }

        container {
          name = "opensearch"
          security_context {
            capabilities {
              drop = ["ALL"]
            }
            run_as_user     = 1000
            run_as_non_root = true
          }
          
          image = "opensearchproject/opensearch:2.14.0"
          image_pull_policy = "IfNotPresent"
          readiness_probe {
            tcp_socket {
              port = 9200
            }
            period_seconds = 5
            timeout_seconds = 3
            failure_threshold = 3
          }

          startup_probe {
            failure_threshold = 30
            initial_delay_seconds = 5
            period_seconds = 10
            tcp_socket {
              port = 9200
            }
            timeout_seconds = 3
          }

          port {
            name = "http"
            container_port = 9200
          }

          port {
            name = "transport"
            container_port = 9300
          }

          port {
            name = "metrics"
            container_port = 9600
          }

          resources {
            requests = {
              cpu    = "1000m"
              memory = "100Mi"
            }
          }

          env {
            name = "node.name"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "cluster.initial_master_nodes"
            value = "opensearch-cluster-master-0,opensearch-cluster-master-1,opensearch-cluster-master-2,"
          }

          env {
            name  = "discovery.seed_hosts"
            value = "opensearch-cluster-master-headless"
          }

          env {
            name  = "cluster.name"
            value = "opensearch-cluster"
          }

          env {
            name  = "network.host"
            value = "0.0.0.0"
          }

          env {
            name  = "OPENSEARCH_JAVA_OPTS"
            value = "-Xmx512M -Xms512M"
          }
          
          env {
            name  = "node.roles"
            value = "master,ingest,data,remote_cluster_client,"
          }

          env {
            name  = "OPENSEARCH_INITIAL_ADMIN_PASSWORD"
            value = "Strongpassword123$$"
          }

          volume_mount {
            name       = "opensearch-cluster-master"
            mount_path = "/usr/share/opensearch/data"
          }

          volume_mount {
            name       = "config-emptydir"
            mount_path = "/usr/share/opensearch/config/opensearch.yml"
            sub_path   = "opensearch.yml"
          }
        }
      }
    }
  }
}
