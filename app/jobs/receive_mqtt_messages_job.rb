class ReceiveMqttMessagesJob < ActiveJob::Base
  self.queue_adapter = :sucker_punch

  def perform()
    # Do something later
    mqtt_client = SinapseMQTTClientSingleton.instance

    if mqtt_client.connected?
    	puts "MQTT client connected to a Broker"
    else
    	puts "MQTT client not connected to a Broker"
    end
   	
	mqtt_client.receive_messages_from_subscribed_topics do |topic, message|
				
		EPD_SIMULATOR_LOGGER.info("Message: " + message + " received in topic: " + topic)
				
		mqtt_client.messages_received.push("Message: " + message + " received in topic: " + topic)

	      #unless /^[0-9a-fA-F]{6}$/.match(address).nil? then

	      
	    if topic.match(Rails.application.config.subscription_root)
	        
	    	message_parties = message.split(";")
	       	message_type = message_parties[0]

	       	topic_parties = topic.split("/")
	        epd_id = topic_parties.last # It is not necessary to check if the epd_id exists because the client is only subscribed to the topics related with its IDs
		    case 

		          when message_type == "1" # Pull measurement
		            EPD_SIMULATOR_LOGGER.info("Processing actuation message received for End Point Device: " + message + " in the topic: " + topic )
		            process_pull_measurement_message(epd_id)

		          when message_type == "2" 
		            EPD_SIMULATOR_LOGGER.info("Processing actuation message received for End Point Device: " + message + " in the topic: " + topic )
		            message_parties.delete_at(0) #Removing id of the message
                process_lighting_profile_message(epd_id, message_parties)

				      when message_type == "3" # On demmand actuation
		            EPD_SIMULATOR_LOGGER.info("Processing actuation message received for End Point Device: " + message + " in the topic: " + topic )
		            dimming = message_parties[1]
		            process_on_demmand_message(epd_id, dimming)			          

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



  # Input: Epd_id is the id_radio of the device
  def process_pull_measurement_message(epd_id)
  	# TODO
  	# To send status message
  	epd_model = Epd.new
  	device = Epd.find_by(id_radio: epd_id)
  	result, message = epd_model.send_status(device.id)
  	
  	if result
  		EPD_SIMULATOR_LOGGER.info("Pull measurement correctly processed. Message sent: " + message)
  	else
  		EPD_SIMULATOR_LOGGER.error("Pull measurement was not processed due MQTT Client Broker: " + message)
  	end
  end


  def process_lighting_profile_message(epd_id, message_array)
  	#TODO
    lighting_profile_model = LightingProfile.new
    
    # To check validity of message
    valid = check_validity_of_profile(message_array)
    
    # To save message in database -> In order to be returned if necessary
    if valid
      # To save message in database -> In order to be returned if necessary
      msg = message_array.join(";") + ";"
      saved = lighting_profile_model.set_lighting_profile(epd_id, msg)
      if saved
        # To create scheduler actions (using on_demmand_scheduler library)
      end 

    end
 
  end


  def process_on_demmand_message(epd_id, dimming)
  	#TODO
  	# To change the status of the EPD
  	epd_model = Epd.new
  	device = Epd.find_by(id_radio: epd_id)
  	dimming = dimming.to_i
  	case 
  		when dimming >= 0 && dimming < 10 # Turn OFF
  			EPD_SIMULATOR_LOGGER.info("On demmand message received: Turn OFF")
  			epd_model.turn_off(device.id)
  		when dimming >= 10 && dimming <= 90 # Dimming
  			EPD_SIMULATOR_LOGGER.info("On demmand message received: Dimming " + dimming.to_s)
  			epd_model.dimming(device.id, dimming)
  		when dimming > 90 && dimming <= 100 # Turn ON
  			EPD_SIMULATOR_LOGGER.info("On demmand message received: Turn ON")
  			epd_model.turn_on(device.id)
  		else
  			EPD_SIMULATOR_LOGGER.info("On demmand message not processed because the dimming value is unknown: " + dimming.to_s)
  	end

  end


  def process_periodic_measurement_interval_set_message(message)
  	#TODO
  end


  def process_configure_thresholds(message)
  	#TODO
  end





##### Helpers methods #####

def check_validity_of_profile(message)
  result = false
  if message.size.even? #It should contains par elements : 100, 13:20, 0, 19:30
    dimming_elements = message.values_at(* message.each_index.select(&:even?)) # Get even elements (dimming)
    time_elements = message.values_at(* message.each_index.select(&:odd?)) # Get odd elements (timing)
    if check_validity_of_dimming(dimming_elements) && check_validity_of_time(time_elements)
      result = true
    end
  end
  return result
end

def check_validity_of_dimming(dimming_array)
  result = true
  dimming_array.each do |dimming|
    if dimming.to_i < 0 || dimming.to_i > 100 || !(dimming !~ /\D/) # Not a nomber
      result = false
      EPD_SIMULATOR_LOGGER.info("Dimming not valid: " + dimming.to_s)
    end
  end
  return result
end

def check_validity_of_time(time_array)
  result = true
  time_array.each do |time|
    begin 
      Time.parse(time)
    rescue
      result = false
      EPD_SIMULATOR_LOGGER.info("Time not valid: " + time.to_s)
    end
  end
  return result
end