# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DurableWebsockets::Connection do
  let(:bunny) { instance_double(Bunny::Session) }
  let(:channel) { instance_double(Bunny::Channel) }
  let(:exchange) { instance_double(Bunny::Exchange) }
  subject { described_class.new('amqp://localhost/websocket') }

  before do
    allow(::Bunny).to receive(:new).and_return(bunny)
    allow(bunny).to receive(:start)
    allow(bunny).to receive(:create_channel).and_return(channel)
    allow(channel).to receive(:topic).and_return(exchange)
    allow(channel).to receive(:fanout).and_return(exchange)
    allow(channel).to receive(:direct).and_return(exchange)
  end

  describe '#initialize' do
    it 'connects to RabbitMQ' do
      described_class.new('amqp://localhost/websocket')
      expect(::Bunny).to have_received(:new).with('amqp://localhost/websocket')
      expect(bunny).to have_received(:start)
      expect(bunny).to have_received(:create_channel)
    end

    it 'creates default exchanges with no block given' do
      described_class.new('amqp://localhost/websocket')
      expect(subject.exchanges).to \
        eq(
          pubsub:    exchange,
          broadcast: exchange,
        )
    end

    it 'creates custom exchanges with block given' do
      subject = described_class.new('amqp://localhost/websocket') do |channel|
        {
          customers: channel.topic('customers', passive: true),
          updates:   channel.direct('updates', passive: true),
        }
      end
      expect(subject.exchanges).to \
        eq(
          customers: exchange,
          updates:   exchange,
        )
    end
  end
end
