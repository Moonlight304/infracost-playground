variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "East US"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM (e.g. Standard_B2s, Standard_D2s_v3)"
  type        = string
  default     = "Standard_B2s"
}

variable "os_type" {
  description = "OS type: 'linux' or 'windows'"
  type        = string
  default     = "linux"

  validation {
    condition     = contains(["linux", "windows"], var.os_type)
    error_message = "os_type must be either 'linux' or 'windows'."
  }
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

# Linux only
variable "ssh_public_key" {
  description = "SSH public key for Linux VM authentication"
  type        = string
  default     = null
}

# Windows only
variable "admin_password" {
  description = "Admin password for Windows VM (min 12 chars, mixed case, number, special char)"
  type        = string
  default     = null
  sensitive   = true
}
