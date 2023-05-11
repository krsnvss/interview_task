terraform {
  required_version = ">= 0.12"
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "= 3.7.0"
    }
  }
}

variable "ssh_key_file" {
  type = string
}

variable "user_pass" {
  type = string
}

provider "vcd" {
  org = "org_172041"
  url = "https://vcd1.vdcportal.ru/api"
  vdc = "vdc_172041_standard"
}

resource "vcd_vapp" "interview" {
  name        = "interview"
  description = "Virtual machines for practical interview"
}

resource "vcd_vapp_org_network" "interview" {
  vapp_name        = vcd_vapp.interview.name
  org_network_name = "OrgNet_172041"
}

resource "vcd_vapp_vm" "interview-vm" {
  vapp_name       = vcd_vapp.interview.name
  name            = "interview-vm"
  computer_name   = "interview-vm"
  catalog_name    = "local-catalog"
  template_name   = "flatcar_production_vmware_ova"
  memory          = 4096
  cpus            = 4
  cpu_cores       = 4
  storage_profile = "FAST"

  override_template_disk {
    bus_type        = "paravirtual"
    size_in_mb      = "32768"
    bus_number      = 0
    unit_number     = 0
  }

  guest_properties = {
    "guest.hostname"   = "interview-vm"
    "guestinfo.ignition.config.data" = base64encode(
      templatefile("${path.cwd}/ignition.json.tmpl",
        {
          ip_dev = "ens192"
          ip_addr = "192.168.0.2/24"
          gw_addr = "192.168.0.1"
          dns_addr = "195.208.4.1"
          user = "candidate"
          password = bcrypt(var.user_pass)
          ssh_key = "${file(var.ssh_key_file)}"
          hostname = "interview-vm"
          ntp_addrs = ["ntp0.ntp-servers.net", "ntp1.ntp-servers.net", "ntp2.ntp-servers.net"]
          ntp_fallback_addrs = ["0.ru.pool.ntp.org", "1.ru.pool.ntp.org", "2.ru.pool.ntp.org"]
          tz = "Europe/Moscow"
        }
      )
    )
    "guestinfo.ignition.config.data.encoding" = "base64"
  }

  network {
    type               = "org"
    name               = vcd_vapp_org_network.interview.org_network_name
    adapter_type       = "VMXNET3"
    ip_allocation_mode = "MANUAL"
    ip                 = "192.168.0.2"
  }

  depends_on = [
    vcd_vapp_org_network.interview
  ]

}