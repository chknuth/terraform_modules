data "aws_availability_zones" "all" {}

data "terraform_remote_state" "db" {
	backend = "s3"

	config {

		bucket = "${var.db_remote_state_bucket}"
		key = "${var.db_remote_state_key}"
		region = "eu-central-1"
	}
}

data "template_file" "user_data" {
	template = "${file("${path.module}/user-data.sh")}"

	vars {
		server_port = "${var.server_port}"
		db_address = "${data.terraform_remote_state.db.address}"
		db_port = "${data.terraform_remote_state.db.port}"
	}
}

resource "aws_launch_configuration" "example" {
	image_id	= "ami-6137648a"
	instance_type	= "${var.instance_type}"
	# key_name	= "deployer-key"
	security_groups = ["${aws_security_group.instance.id}"]
 
	user_data = "${data.template_file.user_data.rendered}"

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_security_group" "instance" {
	name = "${var.cluster_name}-instance"

	ingress {
		from_port 	= "${var.server_port}"
		to_port		= "${var.server_port}"
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_autoscaling_group" "example" {
	launch_configuration = "${aws_launch_configuration.example.id}"
	availability_zones = ["${data.aws_availability_zones.all.names}"]

	load_balancers		= ["${aws_elb.example.name}"]
	health_check_type	= "ELB"

	min_size = "${var.min_size}"
	max_size = "${var.max_size}"
	desired_capacity = 2

	tag {
		key			= "Name"
		value			= "${var.cluster_name}-asg-example"
		propagate_at_launch	= true
	}
}

resource "aws_elb" "example" {
	name			= "${var.cluster_name}-asg-example"
	availability_zones	= ["${data.aws_availability_zones.all.names}"]
	security_groups		= ["${aws_security_group.elb.id}"]

	listener {
		lb_port		= 80
		lb_protocol	= "http"
		instance_port	= "${var.server_port}"
		instance_protocol = "http"
	}

	health_check {
		healthy_threshold	= 2
		unhealthy_threshold	= 2
		timeout			= 3
		interval		= 30
		target			= "HTTP:${var.server_port}/"
	}
}

resource "aws_security_group" "elb" {
	name = "${var.cluster_name}-elb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
	type = "ingress"
	security_group_id = "${aws_security_group.elb.id}"

	from_port	= 80
	to_port		= 80
	protocol	= "tcp"
	cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
	type = "egress"
	security_group_id = "${aws_security_group.elb.id}"

	from_port	= 0
	to_port		= 0
	protocol	= "-1"
	cidr_blocks	= ["0.0.0.0/0"]
}
/*
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
*/
