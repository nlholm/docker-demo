# -*- mode: ruby -*-
# vi: set ft=ruby :

# Project: Docker & SaltStack Load Balancing Demo
# Description: Defines a Master-Minion architecture using Debian 12 (Bookworm).

Vagrant.configure("2") do |config|
  # Use Debian 12 (Bookworm) as the base OS image for all VMs
  config.vm.box = "debian/bookworm64"

  # ---------------------------
  # MASTER NODE
  # Role: SaltStack Master Server
  # ---------------------------
  config.vm.define "master", primary: true do |master|
    master.vm.hostname = "master"
    
    # Internal private network for secure Master <-> Minion communication
    master.vm.network "private_network", ip: "192.168.12.10"
    
    # Provisioning script to install and configure Salt Master
    master.vm.provision "shell", path: "scripts/master.sh"

    # VirtualBox Provider Settings
    # Allocate more RAM (2GB) to handle Salt Master overhead efficiently
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048   # RAM: 2 GB
      vb.cpus = 1        # CPU: 1 Core

      # Performance optimizations (for smoother VM operation)
      vb.customize ["modifyvm", :id, "--ioapic", "on"]       # Enable I/O APIC for better I/O handling
      vb.customize ["modifyvm", :id, "--nestedpaging", "on"] # Enable nested paging for memory efficiency
      vb.customize ["modifyvm", :id, "--hwvirtex", "on"]     # Enforce hardware virtualization extensions
      vb.customize ["modifyvm", :id, "--pae", "on"]          # Enable Physical Address Extension
    end
  end

  # ---------------------------
  # MINION NODE
  # Role: Runs Docker Engine, Nginx Load Balancer, and Containers
  # ---------------------------
  config.vm.define "minion1" do |minion|
    minion.vm.hostname = "minion1"
    
    # Internal private network to connect with the Master
    minion.vm.network "private_network", ip: "192.168.12.11"

    # 1. MAIN DEMO PORT: Forward Host 8080 -> Guest Load Balancer 80
    # Allows accessing the load balancer from Windows browser at http://localhost:8080
    minion.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true

    # 2. DEBUG PORTS: Direct access to individual containers (bypassing Load Balancer)
    # Allows debugging specific containers at localhost:8081, 8082, 8083
    minion.vm.network "forwarded_port", guest: 8081, host: 8081, auto_correct: true
    minion.vm.network "forwarded_port", guest: 8082, host: 8082, auto_correct: true
    minion.vm.network "forwarded_port", guest: 8083, host: 8083, auto_correct: true

    # Provisioning script to install Salt Minion and Docker
    minion.vm.provision "shell", path: "scripts/minion.sh"

    # VirtualBox Provider Settings
    # Allocate 2GB RAM (critical for running Docker Engine + 3 Nginx Containers)
    minion.vm.provider "virtualbox" do |vb|
      vb.memory = 2048   # RAM: 2 GB
      vb.cpus = 1        # CPU: 1 Core  
      
      # Performance optimizations (critical for Docker performance)
      vb.customize ["modifyvm", :id, "--ioapic", "on"]       # Enable I/O APIC
      vb.customize ["modifyvm", :id, "--nestedpaging", "on"] # Enable nested paging
      vb.customize ["modifyvm", :id, "--hwvirtex", "on"]     # Enforce hardware virtualization
      vb.customize ["modifyvm", :id, "--pae", "on"]          # Enable PAE
    end
  end

end