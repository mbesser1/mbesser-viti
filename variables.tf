variable "database_user" {
  description = "Username for the database"
  type        = string
  default     = "admin"
}

variable "database_password" {
  description = "Password for the database"
  type        = string
  default     = "abcd1234"
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "wordpressdb"
  
}