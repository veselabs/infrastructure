variable "name" {
  type        = string
  description = "The name of the GitHub repository"
}

variable "default_branch" {
  type        = string
  description = "The default branch to use for the GitHub repository"
}

variable "environments" {
  type = set(string)
}
