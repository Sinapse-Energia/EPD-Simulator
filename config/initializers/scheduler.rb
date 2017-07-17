#
# config/initializers/scheduler.rb

require 'rufus-scheduler'
#require 'solareventcalculator'

# Let's use the rufus-scheduler singleton
#
rufus = Rufus::Scheduler.singleton


# Testing the correct behaviour of Rufus scheduler
rufus.every '15m' do

 EPD_SIMULATOR_LOGGER.info "Rufus working correctly"
end

# The lighting profiles are created after each restart
rufus.in '1m' do
 	ON_DEMMAND_SCHEDULER.create_all_scheduled_actions_as_on_demmand_actions
end