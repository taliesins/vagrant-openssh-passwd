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
        @logger             = Log4r::Logger.new("vagrant::vagrant_openssh_passwd")
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
        @passwd_path               = nil if @passwd_path == UNSET_VALUE || @passwd_path == 'C:\\Program Files\\OpenSSH\bin\\mkpasswd.exe'
        @mkpasswd_path             = nil if @group_path == UNSET_VALUE || @mkpasswd_path == 'C:\\Program Files\\OpenSSH\\etc\\passwd'
        @group_path                = nil if @group_path == UNSET_VALUE || @group_path == 'C:\\Program Files\\OpenSSH\\etc\\passwd'
        @mkgroup_path              = nil if @mkgroup_path == UNSET_VALUE || @mkgroup_path == 'C:\\Program Files\\OpenSSH\\etc\\passwd'        
      end

      # Validate configuration and return a hash of errors.
      #
      # Validation happens after finalize!.
      #
      # @param [Machine] The current {Machine}
      # @return [Hash] Any errors or {} if no errors found
      def validate(machine)        
        errors = []

        { "vagrant-openssh-passwd " => errors }
      end     
    end
  end
end
