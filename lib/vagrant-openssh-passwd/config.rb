require "vagrant/util/counter"
require "log4r"

module VagrantPlugins
  module OpenSshPasswd    
    # The "Configuration" represents a configuration of how the OpenSshPasswd
    # provisioner should behave.
    class Config < Vagrant.plugin("2", :config)

      # Ahould passwd file be regenerated.
      attr_accessor :generate_passwd

      # Should group file be regenerated.
      attr_accessor :generate_group

      attr_accessor :passwd_path
      attr_accessor :mkpasswd_path
      attr_accessor :group_path
      attr_accessor :mkgroup_path
      

      def initialize
        super
        @generate_passwd    = UNSET_VALUE
        @generate_group     = UNSET_VALUE
        @logger             = Log4r::Logger.new("vagrantplugins::opensshpasswd::config")
      end

      # Final step of the Configuration lifecyle prior to
      # validation.
      #
      # Ensures all attributes are set to defaults if not provided.
      def finalize!
        super

        # Null checks
        @generate_passwd           = nil if @generate_passwd == UNSET_VALUE || @generate_passwd == false
        @generate_group            = nil if @generate_group == UNSET_VALUE || @generate_group == false
        @passwd_path               = nil if @passwd_path == UNSET_VALUE || @passwd_path == 'C:\\Program Files\\OpenSSH\\etc\\passwd'
        @mkpasswd_path             = nil if @group_path == UNSET_VALUE || @mkpasswd_path == 'C:\\Program Files\\OpenSSH\bin\\mkpasswd.exe'
        @group_path                = nil if @group_path == UNSET_VALUE || @group_path == 'C:\\Program Files\\OpenSSH\\etc\\group'
        @mkgroup_path              = nil if @mkgroup_path == UNSET_VALUE || @mkgroup_path == 'C:\\Program Files\\OpenSSH\bin\\mkgroup.exe'
      end

      # Validate configuration and return a hash of errors.
      #
      # Validation happens after finalize!.
      #
      # @param [Machine] The current {Machine}
      # @return [Hash] Any errors or {} if no errors found
      def validate(machine)        
        errors = []

        if  !(!!machine.config.openssh_passwd.generate_passwd  == machine.config.openssh_passwd.generate_passwd)
          errors << "openssh_passwd.generate_passwd must be a boolean"
        end

        if  !(!!machine.config.openssh_passwd.generate_group  == machine.config.openssh_passwd.generate_group)
          errors << "openssh_passwd.generate_group must be a boolean"
        end

        if !machine.config.openssh_passwd.passwd_path.kind_of?(String)
          errors << "openssh_passwd.passwd_path must be a string"
        end

        if !machine.config.openssh_passwd.mkpasswd_path.kind_of?(String)
          errors << "openssh_passwd.mkpasswd_path must be a string"
        end     
        
        if !machine.config.openssh_passwd.group_path.kind_of?(String)
          errors << "openssh_passwd.group_path must be a string"
        end       
        
        if !machine.config.openssh_passwd.mkgroup_path.kind_of?(String)
          errors << "openssh_passwd.mkgroup_path must be a string"
        end             

        { "vagrant-openssh-passwd " => errors }
      end     
    end
  end
end
