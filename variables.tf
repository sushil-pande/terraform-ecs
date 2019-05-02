
variable "region" {
    description = "The AWS region to create resources in."
    default = "us-east-2"
}
variable "availability_zone" {
    description = "The availability zone"
    default = "us-east-2a"
}

variable "ecs_cluster_name" {
    description = "The name of the Amazon ECS cluster."
    default = "main"
}
variable "amis" {
    description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."
    # TODO: support other regions.
    default = {
        us-east-2 = "ami-0351a163d5f20e068"
    }
}
variable "autoscale_min" {
    default = "1"
    description = "Minimum autoscale (number of EC2)"
}

variable "autoscale_max" {
    default = "4"
    description = "Maximum autoscale (number of EC2)"
}

variable "autoscale_desired" {
    default = "1"
    description = "Desired autoscale (number of EC2)"
}
variable "key_name"{
 description = "Enter the path to the SSH Public Key to add to AWS."
 default = "/Downloads/jenkins.pem"
}

variable "instance_type" {
    default = "t2.micro"
}
