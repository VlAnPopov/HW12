# -*- mode: ruby -*-
# vi: set ft=ruby :

boxes = [
  { :name => "ns01", :box => "centos/7", :memory => 2048, :cpus => 2, :version => "2004.01"},
  { :name => "client", :box => "centos/7", :memory => 2048, :cpus => 2, :version => "2004.01"},
  { :name => "Selinux", :box => "centos/7", :memory => 2048, :cpus => 2, :version => "2004.01"},
 ]

Vagrant.configure("2") do |config|
  boxes.each do |box|
    config.vm.define box[:name] do |target|
      target.vm.provider "virtualbox" do |v|
        v.name = box[:name]
        v.memory = box[:memory]
        v.cpus = box[:cpus]
      end
      target.vm.box = box[:box]
	    target.vm.box_version = box[:version]
      target.vm.hostname = box[:name]
      target.vm.synced_folder ".", "/vagrant"
	    case box[:name]
	      when "ns01"
	        target.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "dns"
		      target.vm.provision "ansible" do |ansible|
            #ansible.verbose = "vvv"
            ansible.playbook = "provisioning/playbook.yml"
            ansible.become = "true"
          end
          target.vm.provision "shell", path: "selinux_module.sh"
	      when "client"
	        target.vm.network "private_network", ip: "192.168.50.15", virtualbox__intnet: "dns"
		      target.vm.provision "ansible" do |ansible|
            #ansible.verbose = "vvv"
            ansible.playbook = "provisioning/playbook.yml"
            ansible.become = "true"
          end
        when "Selinux"
          target.vm.network "forwarded_port", guest: 4881, host: 4881
          target.vm.provision "shell", path: "selinux_part1.sh"
      end
    end
  end
end