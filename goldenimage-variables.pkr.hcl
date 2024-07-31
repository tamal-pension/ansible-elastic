variable "base_path" {
    type = string
    default = "s3://bootstrap-pension-stg/playbooks"
}

variable "tag" {
  type    = string
  default = "latest"
}

variable "app" {
  type    = string
  default = "elasticsearch"
}

variable "extra" {
  default = {
    private_domain = "pension-stg.local"
  }
}

variable "aws_profile" {
  default = "pension-stg"
}