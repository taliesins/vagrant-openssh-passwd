require "log4r"

module VagrantPlugins
  module OpenSshPasswd
    class GeneratePasswd
      def initialize(app, env)
        @logger = Log4r::Logger.new("vagrantplugins::opensshpasswd::generatepasswd")
        @logger.debug("Initialising generate open ssh passwd")
        @app = app
        @machine = nil
        @config = nil
      end

      def needs_generate_passwd?
        command = <<HERE
$passwdPath = '#{@config.passwd_path}'
if (!(Test-Path $passwdPath)) {throw "passwdPath does not exist - '$passwdPath'"}
$mkpasswdPath = '#{@config.mkpasswd_path}'
if (!(Test-Path $mkpasswdPath)) {throw "mkpasswdPath does not exist - '$mkpasswdPath'"}
$passwd = &$mkpasswdPath -L
$currentPasswd = Get-Content $passwdPath -Encoding Ascii
if ($passwd -eq $currentPasswd) {
  return $false
} else {
  return $true
}
HERE
        @machine.communicate.test(command, sudo: true)
      end

      def generate_passwd
        command = <<HERE
$passwdPath = '#{@config.passwd_path}'
if (!(Test-Path $passwdPath)) {throw "passwdPath does not exist - '$passwdPath'"}
$mkpasswdPath = '#{@config.mkpasswd_path}'
if (!(Test-Path $mkpasswdPath)) {throw "mkpasswdPath does not exist - '$mkpasswdPath'"}
$passwd = &$mkpasswdPath -L
$passwd | Set-Content $passwdPath -Encoding Ascii
HERE

        @machine.communicate.shell.powershell(command) do |type, data|
          if type == :stderr
            @machine.ui.error(data, prefix: false)
            raise Vagrant::Errors::VagrantError.new, "vagrant-openssh-passwd: unable to generate_passwd"
          end
        end
      end

      def needs_generate_group?
        command = <<HERE
$groupPath = '#{@config.group_path}'
if (!(Test-Path $groupPath)) {throw "groupPath does not exist - '$groupPath'"}
$mkgroupPath = '#{@config.mkgroup_path}'
if (!(Test-Path $mkgroupPath)) {throw "mkgroupPath does not exist - '$mkgroupPath'"}
$group = &$mkgroupPath -L
$currentGroup = Get-Content $groupPath -Encoding Ascii
if ($group -eq $currentGroup) {
  return $false
} else {
  return $true
}
HERE
        @machine.communicate.test(command, sudo: true)
      end 
        
      def generate_group
        command = <<HERE
$groupPath = '#{@config.group_path}'
if (!(Test-Path $groupPath)) {throw "groupPath does not exist - '$groupPath'"}
$mkgroupPath = '#{@config.mkgroup_path}'
if (!(Test-Path $mkgroupPath)) {throw "mkgroupPath does not exist - '$mkgroupPath'"}
$group = &$groupPath -L
$group | Set-Content $mkgroupPath -Encoding Ascii          
HERE
        @machine.communicate.shell.powershell(command) do |type, data|
          if type == :stderr
            @machine.ui.error(data, prefix: false)
            raise Vagrant::Errors::VagrantError.new, "vagrant-openssh-passwd: unable to generate_group"
          end
        end
      end          

      # The middleware method that is invoked automatically by the Plugin ecosystem.
      # Expected to call the next middleware component in the chain if action should proceed.
      def call(env)
        @machine = env[:machine]
        @config = @machine.config.openssh_passwd

        # Continue the rest of the middleware actions
        @app.call(env)

        if @config && (@config.generate_passwd || @config.generate_group)
          if !@machine.communicate.ready?
            raise Vagrant::Errors::VagrantErrorr.new, "vagrant-openssh-passwd: communicator not ready!"
          end

          if needs_generate_passwd?
            @machine.ui.info("Running mkpasswd for OpenSSH")
            generate_passwd
          end

          if needs_generate_group?
            @machine.ui.info("Running mkgroup for OpenSSH")
            generate_group
          end            
        else
          @logger.debug("No open ssh configuration to regenerate")
        end
      end
    end
  end
end
