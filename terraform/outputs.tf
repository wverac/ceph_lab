output "ceph_master_info" {
  description = "The name and IPs of the Ceph master"
  value = {
    name       = libvirt_domain.ceph_master.name
    admin_ip   = "192.168.100.10"
    cluster_ip = "192.168.101.10"
  }
}

output "ceph_nodes_info" {
  description = "The name and IPs of the Ceph nodes"
  value = {
    for idx in range(0, 3) : "ceph-osd-${idx + 1}" => {
      admin_ip   = "192.168.100.${idx + 20}"
      cluster_ip = "192.168.101.${idx + 20}"
    }
  }
}

output "ceph_mon_info" {
  description = "The name and IPs of the Ceph nodes"
  value = {
    for idx in range(0, 3) : "ceph-mon-${idx + 1}" => {
      admin_ip   = "192.168.100.${idx + 30}"
      cluster_ip = "192.168.101.${idx + 30}"
    }
  }
}

