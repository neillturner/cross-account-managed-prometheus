variable "account_id" {
  description = "Map of account IDs"
  type        = map(string)
  default = {
    default = "123456789"
  }
}
