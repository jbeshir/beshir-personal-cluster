variable "ingress-routes-crd-version" {
  type = string
}

variable "persistent-secrets-bucket-name" {
  type = string
}

variable "persistent-secrets-bucket-contents" {
  type = list(any)
}

variable "ethtruism-namespace-name" {
  type = string
}

variable "ethtruism-http-service-info" {
  type = object({
    name = string,
    port = number
  })
}

variable "howwastoday-namespace-name" {
  type = string
}

variable "howwastoday-http-service-info" {
  type = object({
    name = string,
    port = number
  })
}