class Epd < ActiveRecord::Base
	validates :id_radio, uniqueness: true
	
	def create_epd(id, nominal_power)
		epd = Epd.new
		epd.id_radio = id
		epd.nominal_power = nominal_power
		
		epd.stat = 0
		epd.dstat = 0
		epd.temperature = 30
		epd.current = 0
		epd.voltage = 220
		active_power = (nominal_power * rand(0.05..0.09)).to_f
		epd.active_power = active_power.to_f
		epd.reactive_power = 0
		epd.apparent_power = (active_power * rand(0.95..0.99)).to_f
		epd.aggregated_active_energy = 0
		epd.aggregated_reactive_energy = 0
		epd.aggregated_apparent_energy = 0
		epd.frequency = 50

		epd.save
	end	

	def turn_on(id)
		epd = Epd.find(id)
		
		if !epd.nil?
			epd.stat = 1
			epd.dstat = 100
			epd.temperature = 30 + rand(1..10)

			active_power = (epd.nominal_power * rand(1.05..1.09)).to_f
			voltage = 220 + rand(-5..10)

			epd.current = (active_power / voltage).to_f * 1000
			epd.voltage = voltage
			epd.active_power = active_power
			epd.reactive_power = 0
			epd.apparent_power = (active_power * rand(0.95..0.99)).to_f
			epd.aggregated_active_energy = epd.aggregated_active_energy + active_power # Supossing that the EPD is one hour ON
			epd.aggregated_reactive_energy = 0
			epd.aggregated_apparent_energy = epd.aggregated_apparent_energy + (active_power * rand(0.95..0.99)).to_f 
			epd.frequency = 50 + rand(-2..2)
		end
		result = epd.save
		return result
	end

	def turn_off(id)
		epd = Epd.find(id)
		
		if !epd.nil?
			epd.stat = 0
			epd.dstat = 0
			epd.temperature = 30 - rand(1..10)

			active_power = (epd.nominal_power * rand(0.05..0.09)).to_f
			voltage = 220 + rand(-5..10)

			epd.current = (active_power / voltage).to_f * 1000
			epd.voltage = voltage
			epd.active_power = active_power
			epd.reactive_power = 0
			epd.apparent_power = (active_power * rand(0.95..0.99)).to_f
			epd.aggregated_active_energy = epd.aggregated_active_energy + active_power # Supossing that the EPD is one hour ON
			epd.aggregated_reactive_energy = 0
			epd.aggregated_apparent_energy = epd.aggregated_apparent_energy + (active_power * rand(0.95..0.99)).to_f 
			epd.frequency = 50 + rand(-2..2)
		end
		result = epd.save
		return result
	end

	def dimming(id, dimming)
		epd = Epd.find(id)
		
		if !epd.nil?
			epd.stat = 1
			epd.dstat = dimming.to_i
			epd.temperature = 30 + rand(1..5)

			active_power = (epd.nominal_power * rand(0.95..0.99) * (dimming.to_f / 100.0)).to_f 
			voltage = 220 + rand(-5..10)

			epd.current = (active_power / voltage).to_f * 1000
			epd.voltage = voltage
			epd.active_power = active_power
			epd.reactive_power = 0
			epd.apparent_power = (active_power * rand(0.95..0.99)).to_f
			epd.aggregated_active_energy = epd.aggregated_active_energy + active_power # Supossing that the EPD is one hour ON
			epd.aggregated_reactive_energy = 0
			epd.aggregated_apparent_energy = epd.aggregated_apparent_energy + (active_power * rand(0.95..0.99)).to_f 
			epd.frequency = 50 + rand(-2..2)
		end
		result = epd.save
		return result
	end


	# Methods to send information to the MQTT broker. This actions normally should be performed in a library because will be used by controllers and jobs but by the moment are in the model developed.
	# RAE: To improve

	# Inputs: Id is the id of the device in the database, not the id_radio
   	def send_status(id)
   		epd = Epd.find(id)

		mqtt_client = SinapseMQTTClientSingleton.instance

		if mqtt_client.connected?
			# EPD with data
			status_parameters = {
				id_radio: epd.id_radio,
				temp: epd.temperature,
				stat: epd.stat,
				dstat: epd.dstat,
				voltage: epd.voltage,
				current: epd.current,
				active_power: epd.active_power,
				reactive_power: epd.reactive_power,
				apparent_power: epd.apparent_power,
				aggregated_active_energy: epd.aggregated_active_energy,
				aggregated_reactive_energy: epd.aggregated_reactive_energy,
				aggregated_apparent_energy: epd.aggregated_apparent_energy,
				frequency: epd.frequency
				}

		
			result_simulation= mqtt_client.simulate_status_frame("LU/LUM/SEN", status_parameters)

			message = "Message sent: " + result_simulation[0][:message].to_s + " to topic: " + result_simulation[0][:topic].to_s
			result = true
		else
			message = "Message is not sent because the MQTT client is not connected. Please connect with a Broker"
			result = false
		end

		return result, message
   	end	


end
