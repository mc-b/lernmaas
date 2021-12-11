

variable "module" {
  type    = string
  default = "m122-10"
}

variable "public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPvLEdsh/Vpu22zN3M/lmLE8zEO1alk/aWzIbZVwXJYa1RbNHocyZlvE8XDcv1WqeuVqoQ2DPflkQxdrbp2G08AWYgPNiQrMDkZBHG4GlU2Jhe9kCRiWVx/oVDeK8v3+w2nhFt8Jk/eeQ1+E19JlFak1iYveCpHqa68W3NIWj5b10I9VVPmMJVJ4KbpEpuWNuKH0p0YsUKfTQdvrn42fz5jYS1aV7qCCOOzB3WC833QRy04iHZObxDWIi/IFeIp1Gw2FkzPhoZyx4Fk9bsXfm301IePp9cwzArI2LdcOhwEZ3RW2F7ie2WJlVy5tzJjMGCaE1tZTjiCahLNEeTiTQp public-key@cloud.tbz.ch"
}

variable "ports" {
  type    = list(number)
  default = [22, 80]
}

variable "maas" {
  type    = bool
  default = true
}

