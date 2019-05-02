#Connectin with aws
provider "aws" {
  access_key = "AKIAJK3CS5SMS7XSB7TQ"
  secret_key = "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"                                         
  region     = "us-east-2"
  profile    = "default"
}

#specify creating Cluster
resource "aws_ecs_cluster" "main" {
    name = "${var.ecs_cluster_name}"
}


#Creating Auto-scaling Group for ecs
resource "aws_autoscaling_group" "ecs-cluster" {
    availability_zones = ["${var.availability_zone}"]
    name = "ECS ${var.ecs_cluster_name}"
    min_size = "${var.autoscale_min}"
    max_size = "${var.autoscale_max}"
    desired_capacity = "${var.autoscale_desired}"
    health_check_type = "EC2"
    launch_configuration = "${aws_launch_configuration.ecs.name}"
   
}

#ECS(EC2) launch configuration
resource "aws_launch_configuration" "ecs" {
    name = "ECS ${var.ecs_cluster_name}"
    image_id = "${lookup(var.amis,var.region)}" 
    instance_type = "${var.instance_type}"
    iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
    name ="terraform"
    key_name = "jenkins"
    user_data = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config"
  
}
#Creating Role
resource "aws_iam_role" "ecs_host_role" {
    name = "ecs_host_role"
    assume_role_policy = "${file("policies/ecs-role.json")}"
}
resource "aws_iam_role_policy" "ecs_instance_role_policy" {
    name = "ecs_instance_role_policy"
    policy = "${file("policies/ecs-instance-role-policy.json")}"
    role = "${aws_iam_role.ecs_host_role.id}"
}
resource "aws_iam_role" "ecs_service_role" {
    name = "ecs_service_role"
    assume_role_policy = "${file("policies/ecs-role.json")}"
}
resource "aws_iam_role_policy" "ecs_service_role_policy" {
    name = "ecs_service_role_policy"
    policy = "${file("policies/ecs-service-role-policy.json")}"
    role = "${aws_iam_role.ecs_service_role.id}"
}
resource "aws_iam_instance_profile" "ecs" {
    name = "ecs-instance-profile"
    path = "/"
    role = "${aws_iam_role.ecs_host_role.name}"
}
#Creating repository 
resource "aws_ecr_repository" "ecs_repository" {
  name = "icsp"
}
#ECS Service Configuration
resource "aws_ecs_service" "my-ecs-service" {
  	name            = "my-ecs-service"
  	cluster         = "main"
  	task_definition = "mongo"
  	desired_count   = 2
	deployment_minimum_healthy_percent="50"
	deployment_maximum_percent="100"

}

#Creating Task definition
resource "aws_ecs_task_definition" "mongo" {
  family                = "mongo"
  container_definitions = "${file("task-definition/mongo.json")}"

  volume {
    name      = "efs"
    host_path = "/efs/data/db"
  }
}  
