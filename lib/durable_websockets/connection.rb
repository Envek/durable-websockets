# frozen_string_literal: true

require 'bunny'

class DurableWebsockets
  # Connects to RabbitMQ and declares exchanges
  class Connection
    extend Forwardable

    attr_reader :connection, :channel, :exchanges

    def_delegator :@connection, :stop

    # Creates new connection to RabbitMQ and declares exchanges for use.
    #
    # @param [String, Hash] settings
    #   RabbitMQ URL or settings hash for +Bunny+
    #
    # By default will be created two exchanges:
    #
    #  1. Topic exchange for selective publishing, available as +:pubsub+
    #  2. Fanout exchange for boadcast publishing, available as +:broadcast+
    #
    # You may pass block which will allow you to declare exchanges by your own.
    #
    # @yield [channel] Block for manual exchange declaration
    # @yieldparam [Bunny::Channel] channel RabbitMQ channel
    # @yieldreturn [Hash{Symbol=>Bunny::Exchange}]
    def initialize(settings)
      @connection = ::Bunny.new(settings)
      @connection.start
      @channel = @connection.create_channel

      @exchanges =
        if block_given?
          yield @channel
        else
          default_exchanges
        end
    end

    private

    def default_exchanges
      {
        pubsub:    @channel.topic('durable-websocket-pubsub', default_exchange_options),
        broadcast: @channel.fanout('durable-websocket-broadcast', default_exchange_options),
      }
    end

    def default_exchange_options
      { auto_delete: false, durable: true }
    end
  end
end
