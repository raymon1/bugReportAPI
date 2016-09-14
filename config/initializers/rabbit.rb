
connection = Bunny.new(host: 'localhost')
connection.start
$channel = connection.create_channel
