class MqttController < ApplicationController
	#require 'sinapse_mqtt_client_singleton'

	attr_accessor :mqtt_client
	
	def index
		@mqtt_client = SinapseMQTTClientSingleton.instance
		#@mqtt_client.connect
		#@mqtt_client.connected?
	end

	def connect
		@mqtt_client = SinapseMQTTClientSingleton.instance
		@mqtt = OpenStruct.new(mqtt_params)
		puts "MQTT host: " + @mqtt.host
		
		unless @mqtt_client.connected? then
    
	  		# Init connection variables
	  		@mqtt_client.host = @mqtt.host
	  		@mqtt_client.port = @mqtt.port
	  		@mqtt_client.ssl = @mqtt.tls
	  		@mqtt_client.username = @mqtt.username
	  		@mqtt_client.password = @mqtt.password
	      	@mqtt_client.keep_alive = 3600
			
	      	start_connection
		end
		render 'index'
	end

  def start_connection
    @mqtt_client = SinapseMQTTClientSingleton.instance   
    begin 
      @mqtt_client.set_rf_status_threshold(10) #TODO RAE: This value should be provided by the user
      @mqtt_client.connect()
      @mqtt_client.start_historical_variables_of_MQTT_client_singleton
      # Disconnection management
      @mqtt_client.set_disconnected_by_error(true)
      @mqtt_client.set_performing_test(false)
      
      return true
    rescue Exception => ex
      write_error(ex.message)
      return false 
    end 
  end

	def disconnect
	  @mqtt_client = SinapseMQTTClientSingleton.instance
	  puts "in disconnect"
		if !@mqtt_client.performing_test
	     	@mqtt_client.disconnect
			@mqtt_client.start_historical_variables_of_MQTT_client_singleton # Reset historical variables because the Client doesn't have memory
			  # Disconnection management
	      	@mqtt_client.set_disconnected_by_error(false)

	      	redirect_to mqtt_index_path
	    else
	      #render 'index' # RAE TODO. To fix that, the redirect_to :back is not working well
	      redirect_to :back , notice: "The client can not be disconnected at this moment because a communication test is running" 
	    end
    
	end

	private

	def mqtt_params
		params.require(:mqtt).permit(:host, :port, :tls, :username, :password, :devices, :time_between_mqtt_commands, :period, :time_of_testing, :repetitions, :type_of_test)
	end
end
