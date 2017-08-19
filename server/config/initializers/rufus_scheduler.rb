require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

lines = File.readlines(Rails.root.join('onegin.txt'))
i = 0
total = lines.size;

scheduler.every '1s' do
  timestamp = Time.current.iso8601
  Rails.logger.debug "Send usual message at #{timestamp}"
  message = {id: SecureRandom.uuid, content: lines[i % total]}
  ActionCable.server.broadcast 'TicksChannel', message.to_json
  $rabbitmq_exchange.publish(message.to_json, routing_key: 'ticks', persistent: true, priority: 0)
  i += 1
end
