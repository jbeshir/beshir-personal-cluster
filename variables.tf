variable "project" {
  type    = string
  default = "beshir-personal"
}

variable "persistent-secrets-bucket-contents" {
  type    = list(any)
  default = [] # Used in the test fixture to introduce a data dependency between writing and reading secrets.
}