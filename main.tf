#https://github.com/tehcyx/terraform-provider-kind/blob/master/example/main.tf
#https://registry.terraform.io/providers/tehcyx/kind/latest/docs/resources/cluster
#https://kind.sigs.k8s.io/docs/user/configuration/
resource "kind_cluster" "default" {
    name = var.cluster_name
    wait_for_ready = true
    kubeconfig_path = pathexpand(var.k8s_conf_path)

    kind_config {
        kind = "Cluster"
        api_version = var.kind_api_version

        node {
            role = "control-plane"
            
            kubeadm_config_patches = [
                "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
            ]
            extra_port_mappings {
                container_port = 80
                host_port      = 80
                listen_address  = "0.0.0.0"
            }
            extra_port_mappings {
                container_port = 443
                host_port      = 443
                listen_address  = "0.0.0.0"
            }
        }

        node {
            role = "worker"
        }

        node {
            role = "worker"
        }
        node {
            role = "worker"
        }
    }
}
