class RabbitQueau

  def initialize()
  	# $channel in config/initializers/rabbit.rb
    self.channel = $channel
  end

  def perform(exchange_name, message, number)
  	puts message.to_json
  	q  = channel.queue("bunny.bugs.create", :auto_delete => true)
	exchange  = channel.default_exchange

	q.subscribe do |delivery_info, metadata, payload|
		puts "creating bug"
		Bug.create(JSON.parse(payload))
	end

  message[:number] = number
  message = message.to_json
	exchange.publish(message, :routing_key => q.name)
  end

  private
    attr_accessor :channel
end