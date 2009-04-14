module Sass
  class Environment
    attr_reader :parent
    attr_accessor :start_time

    def initialize(parent = nil, options = nil)
      @vars = {}
      @mixins = {}
      @parent = parent
      @options = options
    end

    def abort?
      start_time && (timeout = options[:timeout]) && (Time.now - start_time > timeout)
    end

    def options
      @options || (parent && parent.options) || {}
    end

    def start_time
      @start_time || (parent && parent.start_time) || nil
    end

    def self.inherited_hash(name)
      class_eval <<RUBY, __FILE__, __LINE__ + 1
        def #{name}(name)
          @#{name}s[name] || @parent && @parent.#{name}(name)
        end

        def set_#{name}(name, value)
          if @parent && @parent.#{name}(name)
            @parent.set_#{name}(name, value)
          else
            @#{name}s[name] = value
          end
        end

        def set_local_#{name}(name, value)
          @#{name}s[name] = value
        end
RUBY
    end
    inherited_hash :var
    inherited_hash :mixin
  end
end
