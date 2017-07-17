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

end
