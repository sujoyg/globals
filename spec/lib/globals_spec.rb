require 'spec_helper'
require 'ostruct'
require File.expand_path('../../../lib/globals.rb', __FILE__)

describe Globals do
  describe '.read' do
    let!(:globals_file) { random_text }

    it 'should work for an environment that is defined in the globals file.' do
      configs = random_hash

      File.open(globals_file, 'w') do |f|
        f.write YAML.dump('development' => configs)
      end

      Globals.read(globals_file, 'development').to_hash.should == configs
    end

    it 'should work for an environment that is not defined in the globals file.' do
      File.open(globals_file, 'w') do |f|
        f.write YAML.dump('development' => random_hash)
      end

      Globals.read(globals_file, 'test').to_hash.should be_empty
    end

    it 'should assume that the default environment is `development` if one is not specified.' do
      development_configs = random_hash
      test_configs = random_hash

      File.open(globals_file, 'w') do |f|
        f.write YAML.dump('development' => development_configs, 'test' => test_configs)
      end

      defined?(Rails).should be_nil
      Globals.read(globals_file).to_hash.should == development_configs
    end

    it 'should raise an error if a feature is not boolean.' do
      File.open(globals_file, 'w') do |f|
        f.write YAML.dump('test' => {'feature' => {'foo' => true, 'bar' => false, 'baz' => 'a'}})
      end

      lambda { Globals.read(globals_file, 'test') }.should raise_error('A feature can only be true or false.')
    end

    it 'should not raise any error if all features are boolean.' do
      File.open(globals_file, 'w') do |f|
        f.write YAML.dump('test' => {'feature' => {'foo' => true, 'bar' => false, 'baz' => true}})
      end

      lambda { Globals.read(globals_file, 'test') }.should_not raise_error
    end
  end

  describe '#override' do
    before do
      globals_file = 'globals.yml'
      File.open('globals.yml', 'w') do |f|
        f.write YAML.dump({'development' => {'company' => 'Google', 'feature' => {'debug' => true, 'solr' => true}}})
      end

      File.open('overrides.yml', 'w') do |f|
        f.write YAML.dump({'development' => {'company' => 'Yahoo!', 'feature' => {'solr' => false}}})
      end

      @globals = Globals.read(globals_file, 'development')
    end

    it 'overrides fields specified in the file' do
      @globals.company.should == 'Google'
      @globals.feature.solr.should be_true

      @globals.override('overrides.yml')

      @globals.company.should == 'Yahoo!'
      @globals.feature.solr.should be_false
    end

    it 'does not override fields not specified in the file' do
      @globals.feature.debug.should be_true
      @globals.override('overrides.yml')
      @globals.feature.debug.should be_true
    end
  end
end