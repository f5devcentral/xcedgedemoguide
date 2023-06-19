resource "volterra_cloud_credentials" "aws_cred" {
  name      = "${var.environment}"
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

resource "volterra_aws_vpc_site" "site" {
  name       = "${var.environment}"
  namespace  = "system"
  aws_region = var.aws_region

  labels = {
    "location": "buytime-ce-site"
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
  disable_internet_vip    = true
  logs_streaming_disabled = true
  egress_gateway_default  = true

  ingress_egress_gw {
    aws_certified_hw = "aws-byol-multi-nic-voltmesh"

	  az_nodes {
      aws_az_name  = "${var.aws_region}a"

      inside_subnet {
        existing_subnet_id = element(aws_subnet.subnet_a.*.id, 0)
      }

      outside_subnet {
        existing_subnet_id = element(aws_subnet.subnet_b.*.id, 0)
      }

      workload_subnet {
        existing_subnet_id = element(aws_subnet.subnet_c.*.id, 0)
      }
	  }

    no_inside_static_routes  = true
    no_outside_static_routes = true
    no_global_network        = true
    no_dc_cluster_group      = true
    sm_connection_public_ip  = true

    performance_enhancement_mode {
      perf_mode_l7_enhanced = true
    }
  }

  no_worker_nodes = true

	depends_on = [
    volterra_cloud_credentials.aws_cred,
    aws_subnet.subnet_a,
    aws_subnet.subnet_b,
    aws_subnet.subnet_c
  ]
}

resource "volterra_cloud_site_labels" "labels" {
  name             = volterra_aws_vpc_site.site.name
  site_type        = "aws_vpc_site"
  labels           = {}
  ignore_on_delete = true
}

resource "volterra_tf_params_action" "action_apply" {
	site_name        = volterra_aws_vpc_site.site.name
	site_kind        = "aws_vpc_site"
	action           = "apply"
	wait_for_action  = true
  ignore_on_update = true

	depends_on = [
    volterra_aws_vpc_site.site,
    aws_subnet.subnet_a,
    aws_subnet.subnet_b,
    aws_subnet.subnet_c
  ]
}

