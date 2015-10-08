require 'spec_helper'
require 'ostruct'
require File.expand_path('../../../lib/globals.rb', __FILE__)

describe Globals do
  describe '.read' do
    let!(:globals_file) { random_text }

    it 'should set settings for an environment to that defined in the file.' do
      configs = random_hash

      File.open(globals_file, 'w') do |f|
        f.write YAML.dump('development' => configs)
      end

      Globals.read(File.read(globals_file), 'development').to_hash.should == configs
    end

    it 'should set settings to empty for an environment not defined in the file.' do
      File.open(globals_file, 'w') do |f|
        f.write YAML.dump('development' => random_hash)
      end

      Globals.read(File.read(globals_file), 'test').to_hash.should be_empty
    end

    it 'should assume that the default environment is `development` if one is not specified.' do
      development_configs = random_hash
      test_configs = random_hash

      File.open(globals_file, 'w') do |f|
        f.write YAML.dump('development' => development_configs, 'test' => test_configs)
      end

      defined?(Rails).should be_nil
      Globals.read(File.read(globals_file)).to_hash.should == development_configs
    end

    it 'should raise an error if a feature is not boolean.' do
      File.open(globals_file, 'w') do |f|
        f.write YAML.dump('test' => {'feature' => {'foo' => true, 'bar' => false, 'baz' => 'a'}})
      end

      lambda { Globals.read(File.read(globals_file), 'test') }.should raise_error('A feature can only be true or false.')
    end

    it 'should not raise any error if all features are boolean.' do
      File.open(globals_file, 'w') do |f|
        f.write YAML.dump('test' => {'feature' => {'foo' => true, 'bar' => false, 'baz' => true}})
      end

      lambda { Globals.read(File.read(globals_file), 'test') }.should_not raise_error
    end

    it 'substitutes variables of the form %{var} using the suppliedsupplied hash.' do
      File.open(globals_file, 'w') do |f|
        f.write YAML.dump('test' => {'key' => 'my value is %{value}'})
      end

      expect(Globals.read(File.read(globals_file), 'test', {value: 'foo'}).to_hash).to eq({'key' => 'my value is foo'})
    end
  end

  describe '#override' do
    before do
      globals_file = 'globals.yml'
      File.open('globals.yml', 'w') do |f|
        f.write YAML.dump({'development' => {'company' => 'Google', 'feature' => {'debug' => true, 'solr' => true}}})
      end

      @globals = Globals.read(File.read(globals_file), 'development')
      @overrides = YAML.dump({'development' => {'company' => 'Yahoo!', 'feature' => {'solr' => false}}})
    end

    it 'overrides fields specified in the file' do
      @globals.company.should == 'Google'
      @globals.feature.solr.should be_true

      @globals.override @overrides

      @globals.company.should == 'Yahoo!'
      @globals.feature.solr.should be_false
    end

    it 'does not override fields not specified in the file' do
      @globals.feature.debug.should be_true
      @globals.override @overrides
      @globals.feature.debug.should be_true
    end
  end
end