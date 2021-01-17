# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY TWO MICROSERVICES: FRONTEND AND BACKEND
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  version = "~> 2.0"
  region  = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE FRONTEND
# ---------------------------------------------------------------------------------------------------------------------

module "frontend" {
  source = "./microservice"

  name                  = "frontend"
  min_size              = 1
  max_size              = 2
  key_name              = "${var.key_name}"
  user_data_script      = "${file("user-data/user-data-frontend.sh")}"
  server_text           = "${var.frontend_server_text}"
  student_alias         = "${var.student_alias}"
  is_internal_alb       = false

  # Pass an output from the backend module to the frontend module. This is the URL of the backend microservice, which
  # the frontend will use for "service calls"
  backend_url = "${module.backend.url}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE BACKEND
# ---------------------------------------------------------------------------------------------------------------------

module "backend" {
  source = "./microservice"

  name                  = "backend"
  min_size              = 1
  max_size              = 3
  key_name              = "${var.key_name}"
  user_data_script      = "${file("user-data/user-data-backend.sh")}"
  server_text           = "${var.backend_server_text}"
  student_alias         = "${var.student_alias}"
  is_internal_alb       = true
}