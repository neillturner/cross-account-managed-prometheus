locals {
  cluster_name = "${terraform.workspace}-${random_string.suffix.result}"
  account = contains(keys(var.accounts), terraform.workspace) ? var.accounts[terraform.workspace] : var.accounts["default"]
}

variable "accounts" {
  type = map(
    object({
      zone                    = string
      cidr                    = string
      private_subnets         = list(string)
      public_subnets          = list(string)
      cluster_version         = number
    })
  )
}
