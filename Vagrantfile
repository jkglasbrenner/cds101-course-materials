# -*- mode: ruby -*-
# vi: set ft=ruby :
$install_ansible = <<-SCRIPT
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-get install -y aptitude
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible
SCRIPT

$install_r_deps = <<-SCRIPT
Rscript -e "dir.create(path = Sys.getenv('R_LIBS_USER'), showWarnings = FALSE, recursive = TRUE)"
Rscript -e "install.packages('remotes', repos = 'https://cran.rstudio.com', quiet = TRUE)"
cd /vagrant && Rscript -e "remotes::install_deps(upgrade = 'always', quiet = TRUE)"
SCRIPT

$install_conda_env = <<-SCRIPT
cd /vagrant && bash -ic "conda env create --quiet --file environment.yml"
bash -ic "conda clean -y -a"
SCRIPT


unless Vagrant.has_plugin?("vagrant-vbguest")
  system("vagrant plugin install vagrant-vbguest")
  puts "Dependencies installed, please try the 'vagrant up' command again."
  exit
end

unless Vagrant.has_plugin?("vagrant-disksize")
  system("vagrant plugin install vagrant-disksize")
  puts "Dependencies installed, please try the 'vagrant up' command again."
  exit
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.disksize.size = '20GB'
  config.vm.network "forwarded_port", guest: 8000, host: 8000, auto_correct: true

  config.vm.provider "virtualbox" do |vb|
    vb.name = "intro-cds-website"
    vb.gui = false

    # Source: https://github.com/rdsubhas/vagrant-faster
    host = RbConfig::CONFIG['host_os']

    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024
    elsif host =~ /mswin|mingw|cygwin/
      cpus = `wmic cpu Get NumberOfCores`.split[1].to_i
      mem = `wmic computersystem Get TotalPhysicalMemory`.split[1].to_i / 1024 / 1024
    end

    mem = mem / 4

    vb.memory = mem
    vb.cpus = cpus / 2
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
 end

  config.vm.provision :shell do |shell|
    shell.name = "Install dependencies"
    shell.inline = $install_ansible
    shell.privileged = true
  end

  config.vm.provision :ansible_local do |ansible|
    ansible.playbook = "playbook.yml"
  end

  config.vm.provision :shell do |shell|
    shell.name = "Install R packages"
    shell.inline = $install_r_deps
    shell.privileged = false
  end

  config.vm.provision :shell do |shell|
    shell.name = "Create conda virtual environment"
    shell.inline = $install_conda_env
    shell.privileged = false
  end
end
