data "aws_availability_zones" "available" {}

locals {
  subnet_groups = [for subnet in cidrsubnets(var.cidr_block, 8, 8, 8) : cidrsubnets(subnet, 4, 4)]
}

// 1. Create our highlevel VPC with an internet gateway attached 
module "service-vpc" {
  source     = "../../modules/vpc"
  name       = "${var.name}-vpc"
  cidr_block = var.cidr_block
}

// 2. Create 6 subnets (1 private, 1 public) in 3 availability zones
module "service-subnet" {
  count = length(local.subnet_groups)

  source             = "../../modules/subnets"
  name               = "${var.name}-subnet-az-${count.index + 1}"
  availability_zone  = data.aws_availability_zones.available.names[count.index]
  public_cidr_block  = local.subnet_groups[count.index][0]
  private_cidr_block = local.subnet_groups[count.index][1]

  vpc_id                = module.service-vpc.vpc_id
  public_route_table_id = module.service-vpc.public_route_table_id
}

// 3. Define our high level security groups for this VPC
//   - one for the load balancer
//   - one for the web servers
module "service-security-groups" {
  source      = "../../modules/security_groups"
  name_prefix = var.name
  vpc_id      = module.service-vpc.vpc_id
}

// 4. Create an application load balancer and attach it to 
// the public subnets using our loadbalancer security group. 
// this security group allows traffic on port 80 and 443 from anywhere 
// and routes traffic to all ports in the webserver security group
module "service-lb" {
  source            = "../../modules/load_balancer"
  name              = "${var.name}-lb"
  security_group_id = module.service-security-groups.loadbalancer_sg_id
  subnet_ids        = [for subnet in module.service-subnet : subnet.public_subnet_id]
}

// 5. Create an instance profile for our EC2 instances so that they can talk to ECS
module "services-machine-role" {
  source = "../../modules/service_role"
  name   = "${var.name}-machine-role"
}

// 6. Create an auto scaling group that launches instances into the 
// public subnets and attaches them to the ECS cluster. We also attach the 
// webserver security group so that they only accept traffic from load balancers 
// and create outbound traffic on any port. We also allocate a public IP 
// to our instances so that they can talk to ECS. 
module "service-machines" {
  source            = "../../modules/machines"
  name_prefix       = var.name
  security_group_id = module.service-security-groups.webserver_sg_id
  subnet_ids        = [for subnet in module.service-subnet : subnet.public_subnet_id]
  instance_profile  = module.services-machine-role.profile_name
  ecs_cluster_name  = "${var.name}-cluster"
  capacity          = length(local.subnet_groups)
  capacity_type     = "t4g.micro"
  public_ip         = true
}

// 7. Create a cluster that our services will run in
module "test-cluster" {
  source                = "../../modules/cluster"
  name                  = "${var.name}-cluster"
  autoscaling_group_arn = module.service-machines.autoscaling_arn
}

//##################################################
// Create a single service definition 
//##################################################

// 8a. Create a service registry for "web"
module "service-registry" {
  source = "../../modules/container_repo"
  name   = "${var.name}-web"
}

// 8b. register the service in ecs
module "service-web-service" {
  source            = "../../modules/service"
  name              = "web"
  cluster_id        = module.test-cluster.cluster_id
  vpc_id            = module.service-vpc.vpc_id
  listener_arn      = module.service-lb.listener_arn
  health_check_path = "/greet"
  instances         = 1
}

