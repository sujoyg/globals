require 'erb'
require 'yaml'

class Globals
  def self.read(globals_file, env='development')
    raise "#{globals_file} does not exist." unless File.exists? globals_file

    env = env.to_s
    yaml = YAML.load ERB.new(File.read globals_file).result
    new(yaml[env] || {}, env)
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

  def to_hash
    @globals
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
