require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '10s' do
  timestamp = Time.current.iso8601
  Rails.logger.debug "Send usual message at #{timestamp}"
  message = {id: SecureRandom.uuid, content: "Usual message at #{timestamp}"}
  ActionCable.server.broadcast 'TicksChannel', message.to_json
  $rabbitmq_exchange.publish(message.to_json, routing_key: 'ticks', persistent: true, priority: 0)
end

scheduler.every '60s' do
  timestamp = Time.current.iso8601
  Rails.logger.debug "Send important message at #{timestamp}"
  message = {id: SecureRandom.uuid, content: "Important message at #{timestamp}"}
  ActionCable.server.broadcast 'TicksChannel', message.to_json
  $rabbitmq_exchange.publish(message.to_json, routing_key: 'ticks', persistent: true, priority: 1)
end
