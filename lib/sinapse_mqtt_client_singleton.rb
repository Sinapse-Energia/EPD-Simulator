
require 'sinapse_mqtt_client'
require 'singleton'

class SinapseMQTTClientSingleton < SinapseEPDSimulatorVodafone
	include Singleton

	attr_reader :messages_received, :topics_subscribed, :disconnected_by_error, :performing_test, :rf_status_threshold

	def start_historical_variables_of_MQTT_client_singleton
		@messages_received = Array.new  #Array where the received messages are saved
		@topics_subscribed = Array.new
	end

	def set_disconnected_by_error(value)
		@disconnected_by_error = value
	end

	def set_performing_test(value)
		@performing_test = value
	end

	def set_rf_status_threshold(value)
		@rf_status_threshold = value
	end
end