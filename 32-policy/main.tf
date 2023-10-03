resource "checkpoint_management_package" "TFdemo" {
  name   = var.package_name
  access = true
}

variable "publish" {
  type        = bool
  default     = false
  description = "Set to true to publish changes"
}

resource "checkpoint_management_publish" "example" {
  count    = var.publish ? 1 : 0
  triggers = ["${timestamp()}"]

}

variable "install" {
  type        = bool
  default     = false
  description = "Set to true to INSTALL POLICY"
}
resource "checkpoint_management_install_policy" "example" {
  count          = var.install ? 1 : 0
  policy_package = var.package_name
  targets        = [var.install_target]
}