variable "instance_alias" {
  type = string
  description = "Alias given to AWS Connect Instance"
}

variable "time_zone" {
  type = string
  description = "Time Zone for Hours of Operation"
  default = "America/Los_Angeles"
}

variable "queue_name" {
  type = string
  description = "Name of the queue"
}