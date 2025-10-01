variable "name" {
  type        = string
  description = "Name of the repository"
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

variable "has_merge_queue" {
  type        = bool
  description = "Whether to merge via a merge queue"
  default     = false
}

variable "environments" {
  type        = set(string)
  description = "Environments for which to require reviews"
  default     = []
}
