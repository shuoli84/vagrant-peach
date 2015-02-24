require "vagrant-peach/version"

module VagrantPeach
  class PeachPlugin < Vagrant.plugin("2")
    name "vagrant-peach"

    command "free-memory" do
      require_relative "vagrant-peach/command"
      Command
    end

    action_hook "Ensure peach tools installed and configured", :machine_action_up do |hook|
      require_relative 'actions/configure_peach'
      hook.append Action::ConfigurePeach
    end
  end
end
