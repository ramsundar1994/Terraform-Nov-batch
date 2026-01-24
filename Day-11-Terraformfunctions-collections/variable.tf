variable "allowed_port" {
  default = ["22", "443", "80"]
}
variable "subnets" {
  default = {
    "dev" = "10.0.0.0/24"
    "testing" = "10.0.1.0/24"
    "prod" = "10.0.2.0/24"
    "nonprod" = "10.0.3.0/24"
  }
}