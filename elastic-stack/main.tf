provider "kubernetes" {
  config_path = "./.kube/config"
}

module "opensearch" {
  source = "../modules/opensearch/opensearch"
  namespace = "elastic-system"
}

module "opensearch-dashboards" {
  source = "../modules/opensearch/opensearch-dashboards"
  namespace = "elastic-system"
}
