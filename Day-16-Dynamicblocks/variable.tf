variable "nsg-rule" {
  default = [
    {
        name = "Allow-RDP"
        priority = "100"
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp",
        source_port_range = "*"
        source_address_prefix = "*"
        destination_address_prefix = "*"
        destination_port_range = "3389"
    },
    {
        name = "Allow-Winrm"
        priority = "110"
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp",
        source_port_range = "*"
        source_address_prefix = "*"
        destination_address_prefix = "*"
        destination_port_range = "5985"
    },
    {
        name = "Allow-Internet"
        priority = "100"
        direction = "Outbound"
        access = "Allow"
        protocol = "Tcp",
        source_port_range = "*"
        source_address_prefix = "*"
        destination_address_prefix = "*"
        destination_port_range = "*"
    }
  ]
}

variable "subnets" {
  default = [
    {
        name = "frontend",
        address_prefix = "10.0.0.0/24"
    },
    {
        name = "backend",
        address_prefix = "10.0.1.0/24"
    }
  ]
}