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
$currentPasswd = Get-Content $passwdPath -Encoding Ascii

$localVagrantUserRegex = "^`(vagrant`).*U-$($env:COMPUTERNAME)\\vagrant.*"
$localWithMachineNameVagrantUserRegex = "^$($env:COMPUTERNAME)\+vagrant.*U-$($env:COMPUTERNAME)\\vagrant.*"
$localVagrantUser = $currentPasswd -match $localVagrantUserRegex
$localWithMachineNameVagrantUser = $currentPasswd -match $localWithMachineNameVagrantUserRegex
$newlocalWithMachineNameVagrantUser = $localVagrantUser -replace "^vagrant(.*)`$", "$($env:COMPUTERNAME)+vagrant`$1"

if ($localWithMachineNameVagrantUser) {
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
$currentPasswd = Get-Content $passwdPath -Encoding Ascii

$localVagrantUserRegex = "^`(vagrant`).*U-$($env:COMPUTERNAME)\\vagrant.*"
$localWithMachineNameVagrantUserRegex = "^$($env:COMPUTERNAME)\+vagrant.*U-$($env:COMPUTERNAME)\\vagrant.*"
$localVagrantUser = $currentPasswd -match $localVagrantUserRegex
$localWithMachineNameVagrantUser = $currentPasswd -match $localWithMachineNameVagrantUserRegex
$newlocalWithMachineNameVagrantUser = $localVagrantUser -replace "^vagrant(.*)`$", "$($env:COMPUTERNAME)+vagrant`$1"

if (!$localWithMachineNameVagrantUser) {
  $currentPasswd += $newlocalWithMachineNameVagrantUser
  $currentPasswd | Set-Content $passwdPath -Encoding Ascii
}

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

      def restart_openssh_service
        command = <<HERE
Restart-Service OpenSSHd -Force
HERE
        @machine.communicate.shell.powershell(command) do |type, data|
          if type == :stderr
            @machine.ui.error(data, prefix: false)
            raise Vagrant::Errors::VagrantError.new, "vagrant-openssh-passwd: unable to restart_openssh_service"
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

          should_generate_passwd = false
          if @config.generate_passwd 
            should_generate_passwd = needs_generate_passwd?
            if should_generate_passwd
              @machine.ui.info("Running mkpasswd for OpenSSH")
              generate_passwd
            end
          end

          should_generate_group = false
          if @config.generate_group 
            should_generate_group = needs_generate_group?
            if should_generate_group
              @machine.ui.info("Running mkgroup for OpenSSH")
              generate_group
            end
          end

          if should_generate_passwd || should_generate_group
            @machine.ui.info("Restarting OpenSSH service as there have been config changes")
            restart_openssh_service
          end
        else
          @logger.debug("No open ssh configuration to regenerate")
        end
      end
    end
  end
end
