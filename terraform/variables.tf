variable "k8s_conf_path" {
  type        = string
  description = "Cluster's kubeconfig"
  default     = "~/.kube/config"
}
variable "cluster_name" {
  type        = string
  description = "Cluster's name"
  default     = "lab-cluster"
}
variable "kind_api_version" {
  type        = string
  description = "Api version"
  default     = "kind.x-k8s.io/v1alpha4"
}