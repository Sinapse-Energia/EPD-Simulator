class OnDemmandScheduler 
	def create_scheduled_actions_as_on_demmand_actions(ap_epd_list, lighting_profile, tag)
    	
    	# RAE TODO: To create a job per action to act over the attached devices. It is necessary to tag it with the the schedule_id

    	# Create JOB per step of the profile
    	lighting_profile.each do |profile_step|
    		start_time = profile_step[:start_time]
    		start_time_by_parts = start_time.split(":")
    		hour = start_time_by_parts[0]
    		minutes = start_time_by_parts[1]

    		job_tag = 'scheduler_on_demmand' 
    		cron_string = "#{minutes} #{hour} * * *"
    		MQTT_LOGGER.info("Creating cron job : " + cron_string )

    		job_id =
    		Rufus::Scheduler.singleton.cron cron_string, :tag => job_tag do
        		MQTT_LOGGER.info("Executing On Demmand Scheduler task for: " + ap_epd_list.to_s)
        		# Create on demmand actions
        		action_todo = "3" #Dimming. Turn ON is equal to Dimming 100 and Turn OFF is equal to Dimming 0
        		args = {dimming: profile_step[:dimming].to_i, broadcast: true}
        		# Test if MQTT client is connected? as in ed_logicaldev.rb?

        		begin
            		ap_epd_list.each do |ap_epd_id|
              			MQTT_LOGGER.info("Sending profile step as a on_demmand action, epd_id_list: " + ap_epd_id[:epd_id_list].to_s + ", ap_id: " + ap_epd_id[:ap_id].to_s)
        
              			# To call the epd_communications_job
              			EPDCommunicationsJob.perform_async(ap_epd_id[:epd_id_list], ap_epd_id[:ap_id].to_s, action_todo, args)
      
            		end
            		#result_type = true
            		#result_msg = "Assigning scheduled behaviour to the selected devices"
          		rescue Exception => ex
            		#TODO RAE: Display an error message to the user
            		MQTT_LOGGER.error ex.message
            		#result_type = false
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

   		ar_flampactuator_calendar_model = ArFlampactuatorCalendar.new
  		ed_logicaldev_model = EdLogicaldev.new
  		c_calendarrule_model =CCalendarrule.new
  		MQTT_LOGGER.info "Sending daily shedules"
  		calendars = EcCalendar.all
  		calendars.each do |calendar|
    		devices = ar_flampactuator_calendar_model.get_logicaldevices_id_in_program(calendar.id)
    		ap_epd_list = ed_logicaldev_model.get_list_ap_epds(devices)
    		actions = c_calendarrule_model.get_info_actions(calendar.id)
    		lighting_profile_list =  c_calendarrule_model.get_lighting_profile_list(actions)
    		#ed_logicaldev_model.create_lighting_profile_over_end_point_devices_MQTT(ap_epd_list, lighting_profile_list)
    		create_scheduled_actions_as_on_demmand_actions(ap_epd_list, lighting_profile_list, tag) # This method creates the needed jobs
   		end
   	end

   	def delete_all_scheduled_actions_as_on_demmand_actions(tag)
   		# TODO: To remove the schedules related with the on_demmand scheduler. (Using TAGS)   		
   		MQTT_LOGGER.info "Removing all the scheduled actions as on demmand actions"

   		jobs = Rufus::Scheduler.singleton.jobs(:tag => tag) #Search for the scheduled jobs
   		
   		jobs.each do |job|
   			Rufus::Scheduler.singleton.unschedule(job)	# Unschedule each job
   		end
   	end

end

ON_DEMMAND_SCHEDULER = OnDemmandScheduler.new