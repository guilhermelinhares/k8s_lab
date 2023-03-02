provider "kind" {}

provider "kubernetes" {
  config_path = pathexpand(var.k8s_conf_path)
}
