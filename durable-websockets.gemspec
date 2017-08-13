# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'durable_websockets/version'

Gem::Specification.new do |spec|
  spec.name          = 'durable-websockets'
  spec.version       = DurableWebsockets::VERSION
  spec.authors       = ['Andrey Novikov']
  spec.email         = ['envek@envek.name']

  spec.summary       = 'Client library to publish durable websocket messages'
  spec.homepage      = 'https://github.com/Envek/durable-websockets'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.requirements << 'RabbitMQ 3.6 or newer'

  spec.add_dependency 'bunny', '~> 2.0'
  spec.add_dependency 'connection_pool', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rubocop'
end
