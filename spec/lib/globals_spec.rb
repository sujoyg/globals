require 'spec_helper'
require File.expand_path('../../../lib/globals.rb', __FILE__)

describe Globals do
  describe '#override' do
    before do
      globals_file = 'config/globals.yml'

      File.stub(:read).with(globals_file).and_return(YAML.dump({'development' => {'company' => 'Google', 'feature' => {'debug' => true, 'solr' => true}}}))
      File.stub(:read).with('overrides.yml').and_return(YAML.dump({'development' => {'company' => 'Yahoo!', 'feature' => {'solr' => false}}}))

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

  it 'raises an error if a feature is not boolean' do
    File.stub(:read).with(anything) do
      YAML.dump('test' => {'feature' => {'foo' => true, 'bar' => false, 'baz' => 'a'}})
    end

    lambda { Globals.read('anything', 'test') }.should raise_error('A feature can only be true or false.')
  end

  it 'does not raise any error if all features are boolean' do
    File.stub(:read).with(anything) do
      YAML.dump('test' => {'feature' => {'foo' => true, 'bar' => false, 'baz' => true}})
    end

    lambda { Globals.read('anything', 'test') }.should_not raise_error
  end
end
