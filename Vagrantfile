# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "dbsol" , primary: true do |dbsol|
    dbsol.vm.box = "solaris11_2-x86_64"
    dbsol.vm.box_url = "https://dl.dropboxusercontent.com/s/uxe9huy08gziwx1/solaris11_2-x86_64.box"
    dbsol.vm.hostname = "dbsol.example.com"

    dbsol.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
    dbsol.vm.synced_folder "/Users/edwin/software", "/software"
#    dbsol.vm.synced_folder "/Users/edwin/software", "/software" , type: "nfs"

    dbsol.vm.network "forwarded_port", guest: 1521, host: 1521

#    dbsol.vm.network :private_network, ip: "10.10.10.10"

    dbsol.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "3512"]
      vb.customize ["modifyvm", :id, "--name", "dbsol"]
    end

#    dbsol.vm.provision :shell, :inline => "ln -sf /vagrant/puppet/hiera.yaml /etc/puppet/hiera.yaml"
#
#    dbsol.vm.provision :puppet do |puppet|
#      puppet.manifests_path    = "puppet/manifests"
#      puppet.module_path       = "puppet/modules"
#      puppet.manifest_file     = "site.pp"
#      puppet.options           = "--verbose --trace --debug --hiera_config /vagrant/puppet/hiera.yaml"
#
#      puppet.facter = {
#        "environment" => "development",
#        "vm_type"     => "vagrant",
#      }
#
#    end

  end


end
