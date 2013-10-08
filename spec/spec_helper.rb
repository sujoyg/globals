require 'fakefs/spec_helpers'
require 'specstar/support/random'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.before do
    FakeFS.activate!
  end

  config.after do
    FakeFS.deactivate!
  end
end