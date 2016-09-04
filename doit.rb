#!/usr/bin/env ruby
#

BASE_DIR=File.dirname(__FILE__)
LIB_DIR=BASE_DIR + '/lib'
INIT_DIR=BASE_DIR + '/init'
$LOAD_PATH.unshift LIB_DIR

require 'awesome_print'
require 'tasting_participant'

BASE_URL='https://staging.whatsmywine.com'
load "#{INIT_DIR}/capybara.rb"


browser = Capybara.current_session

num_ratings = (ARGV[0] || 5).to_i
delay = (ARGV[1] || 5).to_i

robot = TastingParticipant.new(browser, {num_ratings: num_ratings, delay: delay})
robot.go

#browser.visit BASE_URL
#content=browser.body
#puts content
#puts "==============================================================="
#active_tastings_url = BASE_URL + '/tastings/active'
#browser.visit active_tastings_url
#content=browser.body
#puts content




