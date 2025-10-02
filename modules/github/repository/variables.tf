variable "name" {
  type        = string
  description = "Name of the repository"
}

variable "visibility" {
  type        = string
  description = "Visibility of the repository"
  default     = "public"
}

variable "default_branch" {
  type        = string
  description = "Default branch to use for the repository"
}

variable "has_issues" {
  type        = bool
  description = "Whether to enable the Issues feature"
  default     = false
}

variable "environments" {
  type        = set(string)
  description = "Environments for which to require reviews"
  default     = []
}
