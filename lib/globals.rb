require 'erb'
require 'rails'

class Globals
  def self.read(globals_file, env=Rails.env)
    env = env.to_s

    yaml = YAML.load ERB.new(File.read globals_file).result
    if yaml && yaml.include?(env)
       new(yaml[env], env)
    else
      raise "Globals were not defined for environment: #{env} in #{globals_file}"
    end
  end

  def initialize(globals, env)
    @globals = globals
    @environment = env
    @cache = {}

    unless @globals["feature"].nil?
      @globals["feature"].each_pair do |k, v|
        raise "A feature can only be true or false." if ![true, false].include?(v)
      end
    end

    define_accessors
  end

  def override(override_file_path)
    overrides = YAML.load(ERB.new(File.read(override_file_path)).result)[@environment]
    if overrides
      @cache.clear
      recursive_merge @globals, overrides
      define_accessors
    end
  end

  private

  def define_accessors
    @globals.each_pair do |key, value|
      define_singleton_method key do
        if value.is_a?(Hash)
          # Cache the instances for efficiency and allowing stubbing.
          @cache[key] ||= Globals.new(value, @environment)
        else
          value
        end
      end
    end
  end

  def recursive_merge(a, b)
    b.each_pair do |k, v|
      if v.is_a? Hash
        a[k] ||= {}
        recursive_merge(a[k], v)
      else
        a[k] = v
      end
    end
  end
end
