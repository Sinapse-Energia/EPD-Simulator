class OnDemmandScheduler 
	def create_scheduled_actions_as_on_demmand_actions(epd, lighting_profile)
    	
    	# RAE TODO: To create a job per action to act over the attached devices. It is necessary to tag it with the the schedule_id

    	# Create JOB per step of the profile
    	lighting_profile.each do |profile_step|
    		start_time = profile_step[:start_time]
    		start_time_by_parts = start_time.split(":")
    		hour = start_time_by_parts[0]
    		minutes = start_time_by_parts[1]

    		job_tag = 'scheduler_on_demmand' 
    		cron_string = "#{minutes} #{hour} * * *"
    		EPD_SIMULATOR_LOGGER.info("Creating cron job : " + cron_string )

    		job_id =
    		Rufus::Scheduler.singleton.cron cron_string, :tag => job_tag do
        		EPD_SIMULATOR_LOGGER.info("Executing On Demmand Scheduler task for: " + epd.to_s)
        		# Create on demmand actions
        		# To change the status of the EPD
            epd_model = Epd.new
            device = Epd.find_by(id_radio: epd)
            dimming = profile_step[:dimming].to_i
            case 
              when dimming >= 0 && dimming < 10 # Turn OFF
                EPD_SIMULATOR_LOGGER.info("Lighting profile step received: Turn OFF")
                epd_model.turn_off(device.id)
              when dimming >= 10 && dimming <= 90 # Dimming
                EPD_SIMULATOR_LOGGER.info("Lighting profile step received: Dimming " + dimming.to_s)
                epd_model.dimming(device.id, dimming)
              when dimming > 90 && dimming <= 100 # Turn ON
                EPD_SIMULATOR_LOGGER.info("Lighting profile step received: Turn ON")
                epd_model.turn_on(device.id)
              else
               EPD_SIMULATOR_LOGGER.info("Lighting profile step not processed because the dimming value is unknown: " + dimming.to_s)
            end
			 end	

    	end 
   	end

   	# This function delete all the 'scheduler_on_demmand' jobs and create the new ones.
   	def create_all_scheduled_actions_as_on_demmand_actions
   		# TODO: For each calendar in the database, this method will generate a scheduler task for each step of a scheduled action. 
   		
   		tag = 'scheduler_on_demmand' # Tag to locate the jobs

   		# Unschedule all the planned jobs related with a given tag
   		delete_all_scheduled_actions_as_on_demmand_actions(tag)	

      lighting_profile_model = LightingProfile.new
      all_lighting_profile = lighting_profile_model.get_all_lighting_profiles()

  		EPD_SIMULATOR_LOGGER.info "Sending all saved schedules"
  		
  		all_lighting_profile.each do |lighting_profile_element|
        id_radio = lighting_profile_element[:id_radio]
        lighting_profile_steps = lighting_profile_element[:lighting_profile_steps]
    		create_scheduled_actions_as_on_demmand_actions(id_radio, lighting_profile_steps)
   		end
   	end

   	def delete_all_scheduled_actions_as_on_demmand_actions(tag)
   		# TODO: To remove the schedules related with the on_demmand scheduler. (Using TAGS)   		
   		EPD_SIMULATOR_LOGGER.info "Removing all the scheduled actions as on demmand actions"

   		jobs = Rufus::Scheduler.singleton.jobs(:tag => tag) #Search for the scheduled jobs
   		
   		jobs.each do |job|
   			Rufus::Scheduler.singleton.unschedule(job)	# Unschedule each job
   		end
   	end

end

ON_DEMMAND_SCHEDULER = OnDemmandScheduler.new