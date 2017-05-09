
# lib/sinapse_mqtt_logger.rb
class EpdSimulatorLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end

  def log_published_messages(published_list)
  	published_list.each do |published|
  		info("Message: " + published[:message] + " published in the topic: " + published[:topic])
  	end
  end
end

logfile = File.open("#{Rails.root}/log/epd_simulator.log", 'a')  # create log file
logfile.sync = true  # automatically flushes data to file
EPD_SIMULATOR_LOGGER = EpdSimulatorLogger.new(logfile)  # constant accessible anywhere