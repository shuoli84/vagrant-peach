module VagrantPeach
  module Action
    class ConfigurePeach
      include Vagrant::Util

      def initialize(app, env)
        @app = app
      end

      def call(env)
        env[:ui].info 'Configure peach'

        static_files = File.expand_path('../../tools', __FILE__)
        env[:ui].info "Copy files from #{static_files} to /peach/tools"

        machine = env[:machine]
        machine.communicate.sudo 'mkdir -p /peach/tools'
        machine.communicate.sudo 'chown vagrant:vagrant /peach/tools'

        # copy tools into /peach/tools
        machine.communicate.upload "#{static_files}/command.py", '/peach/tools/command.py'
        machine.communicate.upload "#{static_files}/wget", '/peach/tools/wget'
        machine.communicate.upload "#{static_files}/curl", '/peach/tools/curl'

        env[:ui].info 'Configure peach server to 10.0.2.2:5000'
        machine.communicate.sudo 'mkdir -p /etc/peach'
        machine.communicate.sudo 'echo {\\"server\\":\\"10.0.2.2:5000\\"} > /etc/peach/conf.json'

        env[:ui].info 'Setup the PATH env'
        machine.communicate.sudo %Q(sed -e 's|/peach/tools:||g' -i /etc/environment && sed -e 's|PATH="\\(.*\\)"|PATH="/peach/tools:\\1"|g' -i /etc/environment)
        machine.communicate.sudo %Q(sed -e 's|/peach/tools:||g' -i /etc/sudoers && sed -e 's|secure_path="\\(.*\\)"|secure_path="/peach/tools:\\1"|g' -i /etc/sudoers)

        @app.call env
      end
    end
  end
end
