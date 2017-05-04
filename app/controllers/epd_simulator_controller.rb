class EpdSimulatorController < ApplicationController
  def index
   # Get epds
   @epds = Epd.all


  end

  def show
  	
  	if params[:commit] == "Delete"
  	 	device_id = params[:id]
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
  	device_id = params[:id]
	@epd = Epd.find(device_id)

	mqtt_client = SinapseMQTTClientSingleton.instance

	if mqtt_client.connected?
		# EPD with data
		status_parameters = {
			id_radio: @epd.id_radio,
			temp: @epd.temperature,
			stat: @epd.stat,
			dstat: @epd.dstat,
			voltage: @epd.voltage,
			current: @epd.current,
			active_power: @epd.active_power,
			reactive_power: @epd.reactive_power,
			apparent_power: @epd.apparent_power,
			aggregated_active_energy: @epd.aggregated_active_energy,
			aggregated_reactive_energy: @epd.aggregated_reactive_energy,
			aggregated_apparent_energy: @epd.aggregated_apparent_energy,
			frequency: @epd.frequency
		}

		
		result = mqtt_client.simulate_status_frame("LU/LUM/SEN", status_parameters)


		flash.now[:notice] = "Message sent: " + result[0][:message].to_s + " to topic: " + result[0][:topic].to_s
	else
		flash.now[:alert] = "Message is not sent because the MQTT client is not connected. Please connect with a Broker" 
	end
	render :show
  end
end
