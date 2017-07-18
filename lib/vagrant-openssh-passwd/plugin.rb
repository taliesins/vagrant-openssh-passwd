require "vagrant"

module VagrantPlugins
  module OpenSshPasswd
    class Plugin < Vagrant.plugin("2")
      name "vagrant-openssh-passwd"
      description <<-DESC
      This plugin ensures regenerates the passwd adnd group files for OpenSSH
      DESC

      action_hook(:generate_passwd, Plugin::ALL_ACTIONS) do |hook|
        require_relative 'generate_passwd'
        hook.after(Vagrant::Action::Builtin::SyncedFolders, GeneratePasswd)
      end

      config(:openssh_passwd) do
        require_relative 'config'
        Config
      end
    end
  end
end