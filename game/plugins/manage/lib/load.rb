module AresMUSH
  module Manage
    class Load
      include AresMUSH::Plugin

      def after_initialize
        @plugin_manager = Global.plugin_manager
      end

      def want_command?(cmd)
        cmd.logged_in? && cmd.root_is?("load")
      end

      # TODO - Just a prototype
      def on_command(client, cmd)
        plugin_name = cmd.args
        begin
          AresMUSH.send(:remove_const, plugin_name.titlecase)
          @plugin_manager.load_plugin(plugin_name)
          client.emit_success "Reloading '#{plugin_name}' plugin."
        rescue SystemNotFoundException => e
          client.emit_failure "Can't find '#{plugin_name}' plugin."
        rescue Exception => e
          client.emit_failure "Error loading '#{plugin_name}' plugin: #{e.to_s}"
        end
        Global.locale.load!
      end
    end
  end
end