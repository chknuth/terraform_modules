variable "aws_region" {
	description = "The AWS region to use"
}

variable "server_port" {
	description = "The port the server will use for HTTP requests"
	default = 8080
}

variable "cluster_name" {
	description = "The name to use for all the cluster resources"
}

variable "db_remote_state_bucket" {
	description = "The name of the S3 bucket for the database's remote state in S3"
}

variable "db_remote_state_key" {
	description = "The path for the database's remote state in S3"
}

variable "instance_type" {
	description = "The type of EC2 instances to run. E.g. t2.micro"
}

variable "min_size" {
	description = "The minimum number of instances in den EC2 Scaling Group"
}

variable "max_size" {
	description = "The maximum number of instances in den EC2 Scaling Group"
}

variable "enable_autoscaling" {
	description = "If set to true, enable auto scaling"
}

variable "ami" {
	description = "The AMI to run in the cluster"
	default = "ami-6137648a"
}

variable "server_text" {
	description = "The text the web server should return"
	default = "Hello, World"
}
