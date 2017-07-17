class LightingProfile < ActiveRecord::Base
	validates :epd_id, uniqueness: true

	def set_lighting_profile(id_radio, lighting_profile)
		result = false
		epd_record= Epd.find_by(id_radio: id_radio)
		if !epd_record.nil?
			epd_id = epd_record.id
			lighting_profile_record = LightingProfile.find_by(epd_id: epd_id)
			if !lighting_profile_record.nil?
				# Update lighting profile
				lighting_profile_record.profile = lighting_profile
				lighting_profile_record.active = true
				lighting_profile_record.save
			else
				# Create lighing profile
				new_lighting_profile = LightingProfile.new
				new_lighting_profile.epd_id = epd_id
				new_lighting_profile.profile = lighting_profile
				new_lighting_profile.active = true
				new_lighting_profile.save
			end
			result = true
		else
			# TODO: Display id_radio does not exists
			EPD_SIMULATOR_LOGGER.info("Lighting profile not set because device does not exist: " + id_radio.to_s)
			result = false
		end
		return result
	end 

	def get_lighting_profile(id_radio)
		epd_record = Epd.find_by(id_radio: id_radio)
		profile = "NOT_SET" #If there is not a lighting profile for this EPD
		if !epd_record.nil?
			epd_id = epd_record.id
			lighting_profile_record = LightingProfile.find_by(epd_id: epd_id)
			if !lighting_profile_record.nil?
				profile = lighting_profile_record.profile
			end
		else
			EPD_SIMULATOR_LOGGER.info("Device does not exist: " + id_radio.to_s)
		end
		return profile
	end

	def send_lighting_profile(id_radio)
		# Get lighting profile and publish it
	end

	def get_all_lighting_profiles()
		all_lighting_profiles = LightingProfile.all
		all_lighting_profile_array = Array.new	
		
		all_lighting_profiles.each do |lighting_profile|
			id_radio = Epd.find_by(id: lighting_profile.epd_id).id_radio
			message = lighting_profile.profile
			message_array = message.split(";")

			lighting_profile_steps = Array.new
        	dimming_elements = get_dimming_elements(message_array)
        	time_elements = get_time_elements(message_array)
        	
        	dimming_elements.each_with_index do |dimming, index|
          		time = time_elements[index]
          		profile_step = {dimming: dimming, start_time: time}
          		lighting_profile_steps.push(profile_step)
        	end
        	lighting_profile_element = {id_radio: id_radio, lighting_profile_steps: lighting_profile_steps}
        	all_lighting_profile_array.push(lighting_profile_element) 
		end
		return all_lighting_profile_array
	end

	private

	# RAE TODO : Move to helpers. DRY!!!!
	def get_dimming_elements(message)
  		return message.values_at(* message.each_index.select(&:even?)) # Get even elements (dimming)
	end

	def get_time_elements(message)
  		return message.values_at(* message.each_index.select(&:odd?)) # Get odd elements (timing)
	end

end
