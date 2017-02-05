# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.ssh.keep_alive = true
  config.vagrant.host = :detect

#/////////////////////////////////////////////////

  ##### Ansible Server environment
  config.vm.define :ansiserver, primary:true do |ansiserver|
    ansiserver.vm.network "private_network", :name => 'vboxnet0', :adapter => 2, ip: "192.168.56.155", :netmask => "255.255.255.0", auto_config: false
    ansiserver.vm.network "private_network", ip: "192.168.56.155"
    ansiserver.vm.provider :virtualbox do |virtualbox|
      virtualbox.customize ["modifyvm", :id, "--name", "ansiserver"]
      virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      virtualbox.customize ["modifyvm", :id, "--memory", "1024"]
    end

    ansiserver.vm.provision "ansible" do |ansible|
        ansible.playbook       = "ansible/provisioning/playbook.yml"
        ansible.inventory_path = "ansible/provisioning/hosts"
        ansible.sudo           = true
    end
  end

#/////////////////////////////////////////////////

  ##### opendj environment
  config.vm.define :opendj, primary:true do |opendj|

    opendj.vm.network "private_network", :name => 'vboxnet0', :adapter => 2, ip: "192.168.56.156", :netmask => "255.255.255.0", auto_config: false
    opendj.vm.network "private_network", ip: "192.168.56.156"
    opendj.vm.provider :virtualbox do |virtualbox|
      virtualbox.customize ["modifyvm", :id, "--name", "opendj"]
      virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      virtualbox.customize ["modifyvm", :id, "--memory", "1024"]
    end

    opendj.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    opendj.vm.provision :shell, path: "init-opendj.sh"

    opendj.vm.provision "ansible" do |opendj|
        opendj.playbook       = "ansible/provisioning/playbookopendj.yml"
        opendj.inventory_path = "ansible/provisioning/hosts"
        opendj.sudo           = true
    end
  end

#/////////////////////////////////////////////////

end
