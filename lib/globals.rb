require 'erb'
require 'yaml'

class Hash
  def recursive_merge!(that)
    that.each_pair do |k, v|
      if v.is_a?(Hash) && self[k].is_a?(Hash)
        self[k].recursive_merge!(v)
      else
        self[k] = v
      end
    end
  end
end

class Globals
  def initialize(hash, env)
    @globals = hash
    @environment = env
    @cache = {}

    define_accessors
  end

  def self.load(content, env, variables={})
    erb = ERB.new(content).result
    yaml = YAML.load(erb % variables)
    hash = yaml['defaults'] || {}
    hash.recursive_merge!(yaml[env] || {})

    unless hash["feature"].nil?
      hash["feature"].each_pair do |k, v|
        raise "A feature can only be true or false." if ![true, false].include?(v)
      end
    end

    hash
  end

  def self.read(content, env='development', variables={})
    env = env.to_s
    hash = load(content, env, variables)
    new(hash, env)
  end

  def method_missing(field)
    nil
  end

  def override(override_content)
    overrides = self.class.load(override_content, @environment)

    if overrides
      @globals.recursive_merge! overrides
      @cache.clear
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
end
