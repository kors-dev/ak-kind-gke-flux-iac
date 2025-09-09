variable "project_id"   { type = string }
variable "region"       { type = string  default = "europe-central2" }
variable "zone"         { type = string  default = "europe-central2-a" }
variable "name"         { type = string  default = "ak-gke" }
variable "node_count"   { type = number  default = 1 }
variable "machine_type" { type = string  default = "e2-standard-2" }
