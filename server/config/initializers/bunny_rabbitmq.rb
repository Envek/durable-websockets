$rabbitmq_connection = Bunny.new
$rabbitmq_connection.start
$rabbitmq_channel = $rabbitmq_connection.create_channel
$rabbitmq_exchange = $rabbitmq_channel.topic("ticks", auto_delete: false, durable: true)
