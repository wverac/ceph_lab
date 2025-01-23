# Define the base image
resource "libvirt_volume" "os_image" {
  name   = "os-base.qcow2"
  source = var.image_source
  format = "qcow2"
}

# Define cloned OS disks for each node and master
resource "libvirt_volume" "ceph_master_os" {
  name           = "ceph-master-os.qcow2"
  base_volume_id = libvirt_volume.os_image.id
  format         = "qcow2"
  size           = 5368709120
}

resource "libvirt_volume" "ceph_node_os" {
  count          = 3
  name           = "ceph-node-${count.index + 1}-os.qcow2"
  base_volume_id = libvirt_volume.os_image.id
  format         = "qcow2"
  size           = 10737418240
}

resource "libvirt_volume" "ceph_mon_os" {
  count          = 3
  name           = "ceph-mon-${count.index + 1}-os.qcow2"
  base_volume_id = libvirt_volume.os_image.id
  format         = "qcow2"
  size           = 10737418240
}

# cloudinit
data "template_file" "user_data" {
  template = file("${path.module}/user_data.cfg")
}

resource "libvirt_cloudinit_disk" "ceph_master" {
  name      = "ceph-master-cloudinit.iso"
  pool      = "default"
  user_data = data.template_file.user_data.rendered
}

resource "libvirt_cloudinit_disk" "ceph_nodes" {
  count     = 3
  name      = "ceph-node-${count.index + 1}-cloudinit.iso"
  pool      = "default"
  user_data = data.template_file.user_data.rendered
}

resource "libvirt_cloudinit_disk" "ceph_mon" {
  count     = 3
  name      = "ceph-mon-${count.index + 1}-cloudinit.iso"
  pool      = "default"
  user_data = data.template_file.user_data.rendered
}

# Define the additional volumes for nodes
resource "libvirt_volume" "ceph_node_volumes" {
  count  = 9 # 3 nodes with 3 extra volumes each
  name   = "ceph-node-${count.index / 3 + 1}-disk${count.index % 3 + 1}.qcow2"
  size   = 26843545600
  format = "qcow2"
}

# Ceph master configuration
resource "libvirt_domain" "ceph_master" {
  name   = "ceph-master"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.ceph_master.id

  network_interface {
    network_name = libvirt_network.ceph-admin.name
    addresses    = ["192.168.100.10"]
  }

  network_interface {
    network_name = libvirt_network.ceph-cluster.name
    addresses    = ["192.168.101.10"]
  }

  disk {
    volume_id = libvirt_volume.ceph_master_os.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

# Ceph OSDs configuration
resource "libvirt_domain" "ceph_nodes" {
  count  = 3
  name   = "ceph-osd-0${count.index + 1}"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.ceph_nodes[count.index].id

  network_interface {
    network_name = libvirt_network.ceph-admin.name
    addresses    = ["192.168.100.${count.index + 20}"]
  }

  network_interface {
    network_name = libvirt_network.ceph-cluster.name
    addresses    = ["192.168.101.${count.index + 20}"]
  }

  disk {
    volume_id = libvirt_volume.ceph_node_os[count.index].id
  }

  disk {
    volume_id = libvirt_volume.ceph_node_volumes[count.index * 3].id
  }

  disk {
    volume_id = libvirt_volume.ceph_node_volumes[count.index * 3 + 1].id
  }

  disk {
    volume_id = libvirt_volume.ceph_node_volumes[count.index * 3 + 2].id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

# Ceph mon
resource "libvirt_domain" "ceph_mon" {
  count  = 3
  name   = "ceph-mon-0${count.index + 1}"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.ceph_mon[count.index].id

  network_interface {
    network_name = libvirt_network.ceph-admin.name
    addresses    = ["192.168.100.${count.index + 30}"]
  }

  network_interface {
    network_name = libvirt_network.ceph-cluster.name
    addresses    = ["192.168.101.${count.index + 30}"]
  }

  disk {
    volume_id = libvirt_volume.ceph_mon_os[count.index].id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

