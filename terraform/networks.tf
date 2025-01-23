resource "libvirt_network" "ceph-admin" {
  name      = "ceph-admin"
  mode      = "nat"
  addresses = ["${var.network_cidr_ceph_admin}"]
  autostart = true
  dhcp {
    enabled = false
  }
  dns {
    enabled = true
  }
}

resource "libvirt_network" "ceph-cluster" {
  name      = "ceph-cluster"
  mode      = "nat"
  addresses = ["${var.network_cidr_ceph_cluster}"]
  autostart = true
  dhcp {
    enabled = false
  }
  dns {
    enabled = true
  }
}

