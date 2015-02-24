module VagrantPeach
  module Action
    class ConfigurePeach
      include Vagrant::Util

      def initialize(app, env)
        @app    = app
      end

      def call(env)
        env[:ui].info "in the peach configure action"
        static_files = File.expand_path('../../tools', __FILE__)

        env[:ui].info static_files

        machine = env[:machine]
        machine.communicate.sudo "mkdir -p /peach/tools"
        machine.communicate.sudo "chown vagrant:vagrant /peach/tools"

        # copy tools into /peach/tools
        machine.communicate.upload "#{static_files}/command.py", "/peach/tools/command.py"
        machine.communicate.upload "#{static_files}/wget", "/peach/tools/wget"
        machine.communicate.upload "#{static_files}/curl", "/peach/tools/curl"

        # Set the path
        machine.communicate.sudo 'echo "export PATH=/peach/tools:$PATH" > /etc/profile.d/peach.sh'

        # Setup the peach server
        machine.communicate.execute 'echo {\\"server\\":\\"10.0.2.2:5000\\"} > ~/.peach.json'

        @app.call env
      end
    end
  end
end
