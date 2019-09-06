# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

API_VERSION = '2'
vagrant_gui = ENV['VAGRANT_GUI'] if ENV['VAGRANT_GUI']
csi_provider = ENV['CSI_PROVIDER'] if ENV['CSI_PROVIDER']
runtime_userland = 'vagrant_rsync_userland_configs.lst'
template_userland = '/csi/vagrant_rsync_userland_template.lst'

puts 'GUI ENABLED.' if vagrant_gui

Vagrant.configure(API_VERSION) do |config|
  config.vm.box = 'csi/kali_rolling'
  config.ssh.username = 'admin'

  r = Random.new
  ssh_port = r.rand(1025...65535)
  config.vm.network 'forwarded_port', guest: 22, host: ssh_port, id: 'ssh', auto_correct: true

  config.vm.synced_folder(
    '.',
    '/csi',
    type: 'rsync',
    rsync__args: [
      '--progress',
      "--rsync-path='/usr/bin/sudo rsync'",
      '--archive',
      '--delete',
      '-compress',
      '--recursive',
      '--files-from=vagrant_rsync_third_party.lst',
      '--ignore-missing-args'
    ]
  )

  File.open(runtime_userland, 'w') do |f|
    File.readlines(template_userland).each do |line|
      f.puts "etc/userland/#{csi_provider}/#{line.chomp}"
    end
  end

  config.vm.synced_folder(
    '.',
    '/csi',
    type: 'rsync',
    rsync__args: [
      '--progress',
      "--rsync-path='/usr/bin/sudo rsync'",
      '--archive',
      '--delete',
      '-compress',
      '--recursive',
      "--files-from=#{runtime_userland}",
      '--ignore-missing-args'
    ]
  )

  # Load UserLand Configs for Respective Provider
  case csi_provider
  when 'aws'
    config_path = './etc/userland/aws/vagrant.yaml'
  when 'virtualbox'
    config_path = './etc/userland/virtualbox/vagrant.yaml'
    # config.vm.network('public_network')
  when 'vmware'
    config_path = './etc/userland/vmware/vagrant.yaml'
    # config.vm.network('public_network')
  else
    # This is needed when vagrant ssh is executed
    config_path = ''
  end

  if File.exist?(config_path)
    yaml_config = YAML.load_file(config_path)

    hostname = yaml_config['hostname']
    config.vm.hostname = hostname

    config.vm.provider(:virtualbox) do |vb, _override|
      if csi_provider == 'virtualbox'
        if vagrant_gui == 'true'
          vb.gui = true
        else
          vb.gui = false
        end

        vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
        vb.customize ['modifyvm', :id, '--draganddrop', 'bidirectional']
        vb.customize ['modifyvm', :id, '--cpus', yaml_config['cpus']]
        vb.customize ['modifyvm', :id, '--memory', yaml_config['memory']]
        disk_mb = yaml_config['diskMB']
        # TODO: resize vmdk based on /csi/etc/userland/vmware/vagrant.yaml
      end
    end

    %i[vmware_fusion vmware_workstation].each do |vmware_provider|
      config.vm.provider(vmware_provider) do |vm, _override|
        # Workaround until https://github.com/hashicorp/vagrant/issues/10730 is resolved
        vm.ssh_info_public = true
        vm.whitelist_verified = true
        if csi_provider == 'vmware'
          if vagrant_gui == 'true'
            vm.gui = true
          else
            vm.gui = false
          end
          vagrant_vmware_license = yaml_config['vagrant_vmware_license']
          vm.vmx['numvcpus'] = yaml_config['cpus']
          vm.vmx['memsize'] = yaml_config['memory']
          vm.vmx['vhv.enable'] = 'true'
          disk_mb = yaml_config['diskMB']
          # TODO: resize vmdk based on /csi/etc/userland/vmware/vagrant.yaml
        end
      end
    end

    config.vm.provider(:aws) do |aws, override|
      if csi_provider == 'aws'
        override.vm.box = 'dummy'

        # aws_init_script = "#!/bin/bash\necho \"Updating FQDN: #{hostname}\"\ncat /etc/hosts | grep \"#{hostname}\" || sudo sed 's/127.0.0.1/127.0.0.1 #{hostname}/g' -i /etc/hosts\nhostname | grep \"#{hostname}\" || sudo hostname \"#{hostname}\"\nsudo sed -i -e 's/^Defaults.*requiretty/# Defaults requiretty/g' /etc/sudoers\necho 'Defaults:admin !requiretty' >> /etc/sudoers"

        aws.access_key_id = yaml_config['access_key_id']
        aws.secret_access_key = yaml_config['secret_access_key']
        aws.keypair_name = yaml_config['keypair_name']

        case yaml_config['region']
        when 'us-west-1'
          aws.ami = 'ami-042b40f1d8ad9e467'
        when 'us-west-2'
          aws.ami = 'ami-0cf9e176514e607ea'
        when 'us-east-1'
          aws.ami = 'ami-0fdbee18cae2fd4d3'
        when 'us-east-2'
          aws.ami = 'ami-02af5e6db5d0d4029'
        else
          raise "Error: #{yaml_config['region']} not supported."
        end

        aws.block_device_mapping = yaml_config['block_device_mapping']
        aws.region = yaml_config['region']
        aws.monitoring = yaml_config['monitoring']
        aws.elastic_ip = yaml_config['elastic_ip']
        aws.associate_public_ip = yaml_config['associate_public_ip']
        aws.private_ip_address = yaml_config['private_ip_address']
        aws.subnet_id = yaml_config['subnet_id']
        aws.instance_type = yaml_config['instance_type']
        aws.iam_instance_profile_name = yaml_config['iam_instance_profile_name']
        aws.security_groups = yaml_config['security_groups']
        aws.tags = yaml_config['tags']
        # Hack for dealing w/ images that require a pty when using sudo and changing hostname
        # aws.user_data = aws_init_script

        override.ssh.username = 'admin'
        override.ssh.private_key_path = yaml_config['ssh_private_key_path']
        override.dns.record_sets = yaml_config['record_sets']
      end
    end

    # Set CSI_PROVIDER for Guest Deployment
    config.vm.provision :shell, inline: "export CSI_PROVIDER=#{csi_provider}", args: hostname, privileged: false
    # Provision Software Based on UserLand Configurations w/in vagrant_rsync_userland_configs.lst
    # After CSI Box has Booted
    config.vm.provision :shell, path: './vagrant/provisioners/init_env.sh', args: hostname, privileged: false
    config.vm.provision :shell, path: './vagrant/provisioners/csi.sh', args: hostname, privileged: false
    # AWS EC2 Storage is handled via EBS Volumes
    unless csi_provider == 'aws'
      config.vm.provision :shell, path: './vagrant/provisioners/userland_fdisk.sh', args: hostname, privileged: false
      config.vm.provision :reload
      config.vm.provision :shell, path: './vagrant/provisioners/userland_lvm.sh', args: hostname, privileged: false
    end
    config.vm.provision :shell, path: './vagrant/provisioners/metasploit.rb', privileged: false
    config.vm.provision :shell, path: './vagrant/provisioners/openvas.sh', privileged: false
    config.vm.provision :shell, path: './vagrant/provisioners/burpsuite_pro.rb', privileged: false
    config.vm.provision :shell, path: './vagrant/provisioners/jenkins.sh', privileged: false
    config.vm.provision :shell, path: './vagrant/provisioners/apache2.sh', privileged: false
    config.vm.provision :shell, path: './vagrant/provisioners/jenkins_ssh-keygen.rb', privileged: false
    config.vm.provision :shell, path: './vagrant/provisioners/post_install.sh', privileged: false
  end
end

File.unlink(runtime_userland) if File.exist?(runtime_userland)
