resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "volterra_cloud_credentials" "aws_cred" {
  name      = "aws-${var.environment}"
  namespace = "system"
  aws_secret_key {
	  access_key = var.aws_access_key
	  secret_key {
	  	clear_secret_info {
	  		url = "string:///${base64encode(var.aws_secret_key)}"
	  	}
	  }
  }
}

resource "volterra_aws_vpc_site" "appstack" {
  name       = "aws-${var.environment}"
  namespace  = "system"
  aws_region = var.aws_region

  labels = {
    location = "buytime-app-stack"
  }

  blocked_services {
    blocked_sevice {
      dns = false
    }
  }

  aws_cred {
    name      = volterra_cloud_credentials.aws_cred.name
    namespace = volterra_cloud_credentials.aws_cred.namespace
  }

  vpc {
	  vpc_id = element(aws_vpc.vpc.*.id, 0)
  }

  direct_connect_disabled = true
  instance_type           = "t3.xlarge"

  disable_internet_vip = true
  logs_streaming_disabled = true
  ssh_key = tls_private_key.key.public_key_openssh

  voltstack_cluster {
    aws_certified_hw = "aws-byol-voltstack-combo"
	  az_nodes {
	  	aws_az_name = "${var.aws_region}a"
	  	disk_size   = 100
      local_subnet {
        existing_subnet_id = element(aws_subnet.subnet_a.*.id, 0)
      }
	  }

    k8s_cluster {
      name = volterra_k8s_cluster.mk8s.name
    }
  }

  no_worker_nodes = true

	depends_on = [
    volterra_cloud_credentials.aws_cred,
    aws_vpc.vpc,
    aws_subnet.subnet_a
  ]
}

resource "volterra_cloud_site_labels" "labels" {
  name             = volterra_aws_vpc_site.appstack.name
  site_type        = "aws_vpc_site"
  labels           = {}
  ignore_on_delete = true
}

resource "volterra_tf_params_action" "action_apply" {
	site_name       = volterra_aws_vpc_site.appstack.name
	site_kind       = "aws_vpc_site"
	action          = "apply"
	wait_for_action = true
  ignore_on_update = true

	depends_on = [
    volterra_aws_vpc_site.appstack,
  ]
}

data "aws_instance" "appstack" {
  instance_tags = {
    "ves-io-site-name" = "aws-${var.environment}"
  }

  filter {
    name   = "subnet-id"
    values = [element(aws_subnet.subnet_a.*.id, 0)]
  }

  depends_on = [
    volterra_tf_params_action.action_apply
  ]
}

data "aws_network_interface" "appstack" {
  filter {
    name   = "attachment.instance-id"
    values = [data.aws_instance.appstack.id]
  }

  filter {
    name   = "subnet-id"
    values = [element(aws_subnet.subnet_a.*.id, 0)]
  }

  depends_on = [
    volterra_tf_params_action.action_apply
  ]
}

output "appstack_private_ip" {
  value = data.aws_network_interface.appstack.private_ip
}

output "xc_private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}

output "xc_public_key" {
  value = tls_private_key.key.public_key_openssh
}
