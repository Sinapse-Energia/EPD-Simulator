class ReceiveMqttMessagesJob < ActiveJob::Base
  self.queue_adapter = :sucker_punch

  def perform()
    # Do something later
    mqtt_client = SinapseMQTTClientSingleton.instance

    if mqtt_client.connected?
    	puts "MQTT client connected to a Broker"
    else
    	puts "MQTT client not conencted to a Broker"
    end
   	
	mqtt_client.receive_messages_from_subscribed_topics do |topic, message|
				
		EPD_SIMULATOR_LOGGER.info("Message: " + message + " received in topic: " + topic)
				
		mqtt_client.messages_received.push("Message: " + message + " received in topic: " + topic)

	      #unless /^[0-9a-fA-F]{6}$/.match(address).nil? then

	      
	    if topic.match('LU/LUM/ACT')
	        
	    	message_parties = message.split(";")
	       	message_type = message_parties[0]

	       	topic_parties = topic.split("/")
	        epd_id = topic_parties[3]
		    case 

		          when message_type == "1" # Pull measurement
		            EPD_SIMULATOR_LOGGER.info("Processing actuation message received for End Point Device: " + message + " in the topic: " + topic )
		            process_pull_measurement_message(message)

		          when message_type == "2" 
		            EPD_SIMULATOR_LOGGER.info("Processing actuation message received for End Point Device: " + message + " in the topic: " + topic )
		            process_lighting_profile_message(message)

				  when message_type == "3" 
		            EPD_SIMULATOR_LOGGER.info("Processing actuation message received for End Point Device: " + message + " in the topic: " + topic )
		            process_on_demmand_message(message)			          

		          when message_type == "4"
		            EPD_SIMULATOR_LOGGER.info("Processing actuation message received for End Point Device: " + message + " in the topic: " + topic )
		            process_periodic_measurement_interval_set_message(message)
		          
		          when message_type == "6"
		          	EPD_SIMULATOR_LOGGER.info("Processing actuation message received for End Point Device: " + message + " in the topic: " + topic )
		          	process_configure_thresholds(message)
		          else 
		            EPD_SIMULATOR_LOGGER.info(message + " not valid to process the data received")

		    end
	    else
	    	EPD_SIMULATOR_LOGGER.info("Unknown topic: " + topic)
	    end
    end
 end
end



  def process_pull_measurement_message(message)
  	#TODO
  end


  def process_lighting_profile_message(message)
  	#TODO
  end


  def process_on_demmand_message(message)
  	#TODO
  end


  def process_periodic_measurement_interval_set_message(message)
  	#TODO
  end


  def process_configure_thresholds(message)
  	#TODO
  end

