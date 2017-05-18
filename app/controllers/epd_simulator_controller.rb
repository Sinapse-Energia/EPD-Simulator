class EpdSimulatorController < ApplicationController
  def index
   # Get epds
   @epds = Epd.all


  end

  def show
  	
  	if params[:commit] == "Delete"
  	 	device_id = params[:id]
  	 	device = Epd.find(device_id)
  	 	manage_subscription_topics(0, device.id_radio)
  	 	Epd.delete(device_id)
  	 	@epds = Epd.all
  	 	render :index		

  	else 
  		device_id = params[:id]
  		@epd = Epd.find(device_id)
  		render :show
  	end
  end

  # Method that creates an EPD for simulation in the database
  def create_epd
  	id_radio = params[:id_radio]
  	nominal_power = params[:nominal_power]

  	puts "creating EPD: " + id_radio.to_s

  	epd_model = Epd.new 
  	epd_model.create_epd(id_radio, nominal_power)
  	# TODO: Create subscription of the MQTT client to the related topic
  	manage_subscription_topics(1, id_radio)
  	@epds = Epd.all

  	render :index
  end

  def turn_on

  	epd_model = Epd.new
  	device_id = params[:id]

  	
  	result = epd_model.turn_on(device_id)
	
	@epd = Epd.find(device_id) # Refresh the epd
  	flash.now[:notice] = "Turn ON: " + result.to_s
  	render :show
  end

  def turn_off
  	epd_model = Epd.new
  	device_id = params[:id]

  	
  	result = epd_model.turn_off(device_id)
  	
  	@epd = Epd.find(device_id) # Refresh the epd
  	flash.now[:notice] = "Turn OFF: " + result.to_s
  	render :show
  end

  def dimming

  	epd_model = Epd.new
  	device_id = params[:id]
  	dimming = params[:dimming]
  	
  	
  	result = epd_model.dimming(device_id, dimming)
  	
  	@epd = Epd.find(device_id)
  	flash.now[:notice] = "Dimming: " + result.to_s
  	render :show
  end

  def send_status
  	epd_model = Epd.new
  	device_id = params[:id]

  	result, message = epd_model.send_status(device_id)

  	if result
  		flash.now[:notice] = message
  	else
  		flash.now[:alert] = message	
  	end

	@epd = Epd.find(device_id) # Necessary to display the view trough show 

	render :show
  end

  private

  # Types 
  # 0 = unsubscribe
  # 1 = subscribe
  def manage_subscription_topics(type, id_radio)
  	# Get id_radio
  	#device = Epd.find(device_id)
  	#id_radio = device.id_radio

  	# Create the topic
  	topic = "LU/LUM/ACT/"+id_radio.to_s
  	
  	# Get the MQTT Client
  	mqtt_client = SinapseMQTTClientSingleton.instance 
  	if mqtt_client.connected?
	  	if type == 0 # unsubscribe
	  		mqtt_client.unsubscribe(topic)
	  		EPD_SIMULATOR_LOGGER.info("MQTT client unsubscribed from: " + topic)
	  	elsif type == 1 # subscribe
	  		EPD_SIMULATOR_LOGGER.info("MQTT client subscribed to: " + topic)
	  		mqtt_client.subscribe(topic)
	  	end
  	else
  		EPD_SIMULATOR_LOGGER.info("The subscription of the topics can not be managed because the client is disconnected")
  	end

  end
end
