# Introduction

`globals` is an easy way to define environment specific global constants for Rails applications.

# Setup

# `Gemfile`
    source 'http://rubygems.org'

    ...
    gem 'globals', '~> 0.0.2'
    ...
# `config/application.rb`
    require File.expand_path('../boot', __FILE__)
    require 'globals'

    $globals = Globals.read File.expand_path('../globals.yml')

    # Pick the frameworks you want:
    require "active_record/railtie"
    ...
# `config/globals.yml`
    development:
      host: localhost:3000
      ...

    production:
      host: myhost.com
      ...

    test:
      host: test.host
      ...

You can now use these constants anywhere in your application, even in the initializers. In the above example,
`$globals.host` will return `localhost:3000` in development, `myhost.com` in production and `test.host` in test.