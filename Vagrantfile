# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "base"
  config.vm.host_name = "citygenerator.localdomain"

  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210.box"

  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true



  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.

  config.vm.provision :puppet do |puppet|
    puppet.options = "--hiera_config puppet/hiera.yaml"
    puppet.module_path    = "puppet/modules"
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file  = "base.pp"

    puppet.facter = {
        ## tells default.pp that we're running in Vagrant
        "is_vagrant" => true,
    }
 
  end

end
