# frozen_string_literal: true

require_relative 'durable_websockets/version'
require_relative 'durable_websockets/connection'

require 'connection_pool'

# Durable websockets with MQ magic!
class DurableWebsockets
  # @see DurableWebsockets::Connection#initialize
  def initialize(rabbitmq_url = ENV['RABBITMQ_URL'], &block)
    raise ArgumentError, 'You must provide URL to RabbitMQ' unless rabbitmq_url

    @pool = ::ConnectionPool.new(size: ENV.fetch('MAX_THREADS', 5)) do
      Connection.new(rabbitmq_url, &block)
    end
  end

  # Publish a message
  # @param [String]             payload     A message to publish for subscribers
  # @param [Symbol]             to          Name of the exchange
  # @param [String]             routing_key Exchange routing key (see http://rubybunny.info/articles/exchanges.html)
  # @param [Hash{Symbol=>void}] options     Other options and headers to pass into {Bunny::Exchange.publish}
  # @return [void]
  def publish(payload, to: :pubsub, routing_key: nil, **options)
    @pool.with do |connection|
      connection.exchanges.fetch(to).publish(
        payload,
        {
          routing_key: routing_key,
          persistent: true,
        }.merge(options),
      )
    end
  end

  # When you need to publish many messages at once, wrap them into +with+ for performance.
  def with
    @pool.with do |_connection|
      yield self
    end
  end
end
