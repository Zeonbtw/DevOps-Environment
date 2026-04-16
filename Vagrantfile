Vagrant.configure("2") do |config|
  config.vm.box = "generic/debian12"
  config.vm.hostname = "devops-vm"

  # Private IP for local host mapping
  config.vm.network "private_network", ip: "192.168.60.10"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus = 2
  end

  # Provision scripts
  config.vm.provision "shell", path: "scripts/base.sh"
  config.vm.provision "shell", path: "scripts/vault.sh"
  config.vm.provision "shell", path: "scripts/jenkins.sh"
  config.vm.provision "shell", path: "scripts/zabbix.sh"
  config.vm.provision "shell", path: "scripts/apache.sh"
end
