require "much-plugin/version"

module MuchPlugin

  def self.included(receiver)
    receiver.class_eval{ extend ClassMethods }
  end

  module ClassMethods

    # install an included hook that first checks if this plugin's receiver mixin
    # has already been included.  If it has not been, include the receiver mixin
    # and run all of the `plugin_included` hooks
    def included(plugin_receiver)
      return if plugin_receiver.include?(self.much_plugin_included_detector)
      plugin_receiver.send(:include, self.much_plugin_included_detector)

      self.much_plugin_included_hooks.each do |hook|
        plugin_receiver.class_eval(&hook)
      end
    end

    # the included detector is an empty module that is only used to detect if
    # the plugin has been included or not, it doesn't add any behavior or
    # methods to the object receiving the plugin; we use `const_set` to name the
    # module so if its seen in the ancestors it doesn't look like some random
    # module and it can be tracked back to much-plugin
    def much_plugin_included_detector
      @much_plugin_included_detector ||= Module.new.tap do |m|
        self.const_set("MuchPluginIncludedDetector", m)
      end
    end

    def much_plugin_included_hooks; @much_plugin_included_hooks ||= []; end

    def plugin_included(&hook)
      self.much_plugin_included_hooks << hook
    end

  end

end
