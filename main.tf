module "vpc" {
  source = "git::https://github.com/sriteja28/tf-module-vpc.git"

  for_each   = var.vpc
  cidr_block = each.value["cidr_block"]
  subnets    = each.value["subnets"]

  env            = var.env
  tags           = var.tags
  default_vpc_id = var.default_vpc_id
  default_vpc_rt = var.default_vpc_rt

}

module "rabbitmq" {
  source = "git::https://github.com/sriteja28/tf-module-rabbitmq.git"

  for_each      = var.rabbitmq
  component     = each.value["component"]
  instance_type = each.value["instance_type"]

  sg_subnet_cidr = lookup(lookup(lookup(lookup(var.vpc, "main", null), "subnets", null), "app", null), "cidr_block", null)
  vpc_id         = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  subnet_id      = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnet_ids", null), "db", null), "subnet_ids", null)[0]

  env            = var.env
  tags           = var.tags
  allow_ssh_cidr = var.allow_ssh_cidr
  zone_id        = var.zone_id
  kms_key_arn    = var.kms_key_arn
}

module "rds" {
  source = "git::https://github.com/sriteja28/tf-module-rds.git"

  for_each       = var.rds
  component      = each.value["component"]
  engine         = each.value["engine"]
  engine_version = each.value["engine_version"]
  db_name        = each.value["db_name"]
  subnet_ids     = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnet_ids", null), "db", null), "subnet_ids", null)
  instance_count = each.value["instance_count"]
  instance_class = each.value["instance_class"]
  vpc_id = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  sg_subnet_cidr = lookup(lookup(lookup(lookup(var.vpc, "main", null), "subnets", null), "app", null), "cidr_block", null)

  tags        = var.tags
  env         = var.env
  kms_key_arn = var.kms_key_arn
}



module "documentdb" {
  source = "git::https://github.com/sriteja28/tf-module-documentdb.git"

  for_each          = var.documentdb
  component         = each.value["component"]
  subnet_ids        = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnet_ids", null), "db", null), "subnet_ids", null)
  vpc_id            = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  sg_subnet_cidr    = lookup(lookup(lookup(lookup(var.vpc, "main", null), "subnets", null), "app", null), "cidr_block", null)
  engine            = each.value["engine"]
  engine_version    = each.value["engine_version"]
  db_instance_count = each.value["db_instance_count"]
  instance_class    = each.value["instance_class"]

  tags        = var.tags
  env         = var.env
  kms_key_arn = var.kms_key_arn
}

module "elasticache" {
  source = "git::https://github.com/sriteja28/tf-module-elasticache.git"

  for_each                = var.elasticache
  component               = each.value["component"]
  subnet_ids              = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnet_ids", null), "db", null), "subnet_ids", null)
  vpc_id                  = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  sg_subnet_cidr          = lookup(lookup(lookup(lookup(var.vpc, "main", null), "subnets", null), "app", null), "cidr_block", null)
  engine                  = each.value["engine"]
  engine_version          = each.value["engine_version"]
  replicas_per_node_group = each.value["replicas_per_node_group"]
  num_node_groups         = each.value["num_node_groups"]
  node_type               = each.value["node_type"]
  parameter_group_name    = each.value["parameter_group_name"]


  tags        = var.tags
  env         = var.env
  kms_key_arn = var.kms_key_arn
}

module "alb" {
  source = "git::https://github.com/sriteja28/tf-module-alb.git"

  for_each           = var.alb
  name               = each.value["name"]
  internal           = each.value["internal"]
  load_balancer_type = each.value["load_balancer_type"]
  vpc_id             = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  sg_subnet_cidr     = each.value["name"] == "public" ? ["0.0.0.0/0"] : local.app_web_subnet_cidr
  subnets            = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnet_ids", null), each.value["subnet_ref"], null), "subnet_ids", null)

  env  = var.env
  tags = var.tags
}


module "apps" {
  source = "git::https://github.com/sriteja28/tf-module-app.git"

  for_each         = var.apps
  app_port         = each.value["app_port"]
  desired_capacity = each.value["desired_capacity"]
  max_size         = each.value["max_size"]
  min_size         = each.value["min_size"]
  instance_type    = each.value["instance_type"]
  sg_subnets_cidr  = lookup(lookup(lookup(lookup(var.vpc, "main", null), "subnets", null), each.value["subnet_ref"], null), "subnet_ids", null)

  component = each.value["component"]
  subnets   = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnet_ids", null), each.value["subnet_ref"], null), "subnet_ids", null)
  vpc_id    = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  lb_dns_name = lookup(lookup(module.alb, each.value["lb_ref"], null), "dns_name", null)
  listener_arn = lookup(lookup(module.alb, each.value["lb_ref"], null), "listener_arn", null)
  lb_rule_priority = each.value["lb_rule_priority"]

  env         = var.env
  tags        = var.tags
  kms_key_arn = var.kms_key_arn
  allow_ssh_cidr = var.allow_ssh_cidr
}
