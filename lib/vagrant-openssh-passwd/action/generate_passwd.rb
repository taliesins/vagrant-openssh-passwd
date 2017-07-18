module VagrantPlugins
  module OpenSshPasswd
    module Action

      # Regenerate passwd and group files if required
      class GeneratePasswd
        attr_accessor :machine
        attr_accessor :config
        attr_accessor :env
        attr_accessor :app

        def initialize(app, env)
          @logger = Log4r::Logger.new("vagrant::provisioners::vagrant_openssh_passwd")
          @logger.debug("Initialising generate open ssh passwd")
          @app = app
          @env = env
          @machine = env[:machine]

          @machine.config.vm.provisioners.each do |prov|
            @config = prov.config if prov.config.is_a?(VagrantPlugins::OpenSshPasswd::Config)
          end
        end

        # The middleware method that is invoked automatically by the Plugin ecosystem.
        # Expected to call the next middleware component in the chain if action should proceed.
        def call(env)

          if @config and (@config.generate_passwd || @config.generate_group)

          else
            @logger.debug("No open ssh configuration to regenerate")
          end

          # Continue the rest of the middleware actions
          @app.call(env)
        end
      end
    end
  end
end
