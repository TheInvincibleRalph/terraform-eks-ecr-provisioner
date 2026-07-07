aws_region   = "us-east-2"
project_name = "fcmb-prod"
environment  = "production"

cluster_name    = "fcmb-eks-prod"
cluster_version = "1.30"

vpc_cidr = "10.10.0.0/16"

node_instance_types = ["m5.large"]
node_desired_size   = 3
node_min_size       = 3
node_max_size       = 6

# Cost tracking tags
tags = {
  "CostCenter"  = "Finance-Dept"
  "Owner"       = "DevOps-Team"
  "Criticality" = "High"
}