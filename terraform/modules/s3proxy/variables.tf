variable "namespace" {
  description = "The destination namespace"
}

variable "replicas" {
  description = "Number of deployment replicas"
  default = 1
}

variable "storageaccount" {
  description = "Storage Account Name"
}

variable "storagekey" {
  description = "Storage Account Key"
}