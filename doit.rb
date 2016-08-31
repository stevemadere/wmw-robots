#!/usr/bin/env ruby
#

BASE_DIR=File.dirname(__FILE__)
LIB_DIR=BASE_DIR + '/lib'
INIT_DIR=BASE_DIR + '/init'
$LOAD_PATH.unshift LIB_DIR

require 'tasting_participant'

BASE_URL='https://staging.whatsmywine.com'
load "#{INIT_DIR}/capybara.rb"


browser = Capybara.current_session

robot = TastingParticipant.new(browser)
robot.go

#browser.visit BASE_URL
#content=browser.body
#puts content
#puts "==============================================================="
#active_tastings_url = BASE_URL + '/tastings/active'
#browser.visit active_tastings_url
#content=browser.body
#puts content




