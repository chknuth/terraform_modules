data "terraform_remote_state" "db" {
        backend = "s3"

        config {

                bucket = "${var.db_remote_state_bucket}"
                key = "${var.db_remote_state_key}"
                region = "eu-central-1"
        }
}

resource "aws_db_instance" "example" {
	engine = "mysql"
	allocated_storage = 10
	instance_class = "db.t2.micro"
	name = "${var.db_instance_name}"
	username = "admin"
	password = "${var.db_password}"
	skip_final_snapshot = true
}

