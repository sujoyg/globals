require 'erb'
require 'yaml'

class Hash
  def recursive_merge!(that)
    that.each_pair do |k, v|
      if v.is_a? Hash
        self[k] ||= {}
        self[k].recursive_merge!(v)
      else
        self[k] = v
      end
    end
  end
end

class Globals
  def self.load(globals_file, env)
    yaml = YAML.load ERB.new(File.read globals_file).result
    globals = yaml['defaults'] || {}
    globals.recursive_merge!(yaml[env] || {})
    globals
  end

  def self.read(globals_file, env='development')
    raise "#{globals_file} does not exist." unless File.exists? globals_file

    globals = load(globals_file, env)

    new(globals, env)
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
    puts "Override file is " + override_file_path
    overrides = self.class.load(override_file_path, @environment)

    if overrides
      @cache.clear
      @globals.recursive_merge! overrides
      define_accessors
    end

    self
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

  def self.recursive_merge(a, b)
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
