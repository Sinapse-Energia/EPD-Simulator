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
end
