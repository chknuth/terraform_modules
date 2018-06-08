variable "db_password" {
	description = "Password for the database"
}

variable "db_instance_name" {
	description = "Name of the Database Instance"
}

variable "db_remote_state_bucket" {
	description = "Name of the S3 bucket of the database's remote state"
}

variable "db_remote_state_key" {
	description = "The path for the database's remote state in S3"
}

