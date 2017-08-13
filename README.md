Durable WebSockets
==================

Library to publish messages with guaranteed delivery from server application on Ruby to client applications in web browsers with help of [RabbitMQ] 3.6+.

## How it works

It uses [WebStomp plugin for RabbitMQ] and various settings for MQ broker and client libraries to make messages from classic Pub/Sub scheme not to lost in case of network lags and so on but to be delivered to every subscribed device.

What is used:

 1. Persistent messages
 1. Durable exchanges
 2. Per-client durable queue (e.g. queue for every browser tab)
 3. Per-message delivery acknowledgement
 4. WebSTOMP protocol (STOMP over websockets)

See the all used components' docs:

 - http://rubybunny.info/articles/durability.html
 - https://www.rabbitmq.com/stomp.html
 - http://www.rabbitmq.com/web-stomp.html
 - http://jmesnil.net/stomp-websocket/doc/


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'durable-websockets'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install durable-websockets

## Usage

```rb
websocket = DurableWebsockets.new('amqp://localhost/websocket') do |channel|
    {
      customers: channel.topic('customers', passive: true), # Use +passive: true+ if you will create exchanges in RabbitMQ with right parameters beforehand
      updates:   channel.direct('updates', passive: true),  # Or pass +{ auto_delete: false, durable: true }+ (or just use the default exchanges)
    }
  end
end

websocket.publish('{"foo": "bar"}', to: :customers, routing_key: 'customers.1.baz')
```

## Operations guidelines

Please declare all the queues as `auto-delete` (in subscription properties) and auto-expiring in minutes or hours (with `x-expires` [RabbitMQ policy]), so broker will clean them up. This will

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Envek/durable-websockets.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[RabbitMQ]: https://www.rabbitmq.com/
[RabbitMQ policy]: https://www.rabbitmq.com/parameters.html#policies
[WebStomp plugin for RabbitMQ]: https://www.rabbitmq.com/web-stomp.html
