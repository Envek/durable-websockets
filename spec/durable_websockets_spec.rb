# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DurableWebsockets do
  subject { described_class.new('amqp://localhost/websocket') }

  it 'has a version number' do
    expect(DurableWebsockets::VERSION).not_to be nil
  end

  describe('#publish') do
    let(:connection) { instance_double(DurableWebsockets::Connection) }
    let(:exchanges)  { { pubsub: pubsub_exchange } }
    let(:pubsub_exchange){ instance_double(Bunny::Exchange) }

    before do
      allow(DurableWebsockets::Connection).to receive(:new).and_return(connection)
      allow(connection).to receive(:exchanges).and_return(exchanges)
      allow(pubsub_exchange).to receive(:publish)
    end

    it 'publishes persistent message to :pubsub exchange by default' do
      message = '{"foo": "bar"}'
      subject.publish(message, routing_key: 'user.1')
      expect(pubsub_exchange).to have_received(:publish) \
        .with(message, hash_including(routing_key: 'user.1', persistent: true))
    end

    it 'raises error for unknown exchange' do
      expect { subject.publish('{}', to: :unknown) }.to raise_error(KeyError)
    end
  end
end
