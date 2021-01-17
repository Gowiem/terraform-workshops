# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "student_alias" {
  description = "Your student alias"
}

variable "name" {
  description = "The name for the microservice and all resources in this module"
}

variable "min_size" {
  type        = number
  description = "The min number of servers to run in the ASG for this microservice"
}

variable "max_size" {
  type        = number
  description = "The max number of servers to run in the ASG for this microservice"
}

variable "user_data_script" {
  description = "The user data script to run on the microservice server"
}

variable "is_internal_alb" {
  type        = bool
  description = "If set to true, the ALB will be internal, and therefore only accessible from within the VPC"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "key_name" {
  description = "The name of the EC2 Key Pair that can be used to SSH to the EC2 Instances. Leave blank to not associate a Key Pair with the Instances."
  default     = ""
}

variable "server_http_port" {
  type        = number
  description = "The port the EC2 Instances should listen on for HTTP requests"
  default     = 8080
}

variable "alb_http_port" {
  type        = number
  description = "The port the ALB should listen on for HTTP requests"
  default     = 80
}

variable "server_text" {
  description = "The text the server should return for HTTP requests"
  default     = "Hello, World"
}

variable "backend_url" {
  description = "The URL the frontend can use to reach the backend. Leave blank if this is not a frontend."
  default     = ""
}