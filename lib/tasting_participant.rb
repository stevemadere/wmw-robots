#!/usr/bin/env ruby

require 'ostruct'
require 'securerandom'

class TastingParticipant
  BASE_URL='https://staging.whatsmywine.com'
#  BASE_URL='http://localhost:3000'

  def initialize(_browser)
    @browser = _browser
  end

  attr_accessor :browser

  def make_up_credentials
    c = OpenStruct.new
    r = Random.rand(1000000).to_s
    c.name = "JoeRandom" + r
    c.phone_number = "8%09d" % [Random.rand(1000000000)]
    c.email_address =  "steve+#{r}@stevemadere.com"
    c.password = SecureRandom.hex[0,10]
    c
  end

  def credentials
    @credentials ||= make_up_credentials
  end

  def home
    browser.visit BASE_URL
    puts_content
    
  end

  def on_signup_page?
    browser.has_css?('body.signup-page')
  end

  def on_tasting_page?
    browser.has_css?('.show-page.tasting') 
  end

  def on_festival_page?
    browser.has_css?('.show-page.festival')
  end

  def on_festival_booth_select_page?
    browser.has_css?('.festival-booth-select-page')
  end

  def on_exhibitor_booth_page?
    browser.has_css?('.show-page.exhibitor-booth')
  end

  def find_tasting(pattern=nil)
    active_tastings_url = BASE_URL + '/events/active'
    browser.visit active_tastings_url
    puts_content
    tasting_cards = browser.all('div.tasting-details-card')
    the_card = pattern.nil? ? tasting_cards.sample : tasting_cards.detect { |tl| tl.text =~ pattern }
    raise "tasting matching #{pattern} not found" unless the_card
    the_link = the_card.first('a')
    the_link
  end

  def register
    browser.fill_in
  end

  # FIXME:  this is a stub
  def have_account?
    false
  end

  # FIXME:  this is a stub
  def visit_login_page
    raise "UnimplementedFunctionality"
  end


  # FIXME:  this is a stub
  def complete_login_form
    raise "UnimplementedFunctionality"
  end

  def complete_signup_form
    browser.fill_in('user[name]',with: credentials.name)
    browser.fill_in('user[phone_number]',with: credentials.phone_number)
    browser.fill_in('user[email_address]',with: credentials.email_address)
    browser.fill_in('user[password]',with: credentials.password)
    browser.fill_in('user[password_confirmation]',with: credentials.password)
    browser.click_button('Signup')
    puts_content
  end

  def signup_or_login
    if have_account?
      visit_login_page
      complete_login_form
    else
      complete_signup_form
    end
  end

  def go_to_tasting(tasting_link)
    tasting_link.click
    puts_content
    if on_signup_page?
      signup_or_login
    end
    raise "Expected to be on a tasting page" unless (on_tasting_page? || on_festival_page?)
  end

  def select_random_category
    category_buttons = browser.all('.category-button')
    chosen_category = category_buttons.to_a.sample
    chosen_category.click
    raise "Expected to be on a festival booth select page" unless on_festival_booth_select_page?
  end

  def select_random_booth
    booth_links = browser.all('.booth-link')
    chosen_booth = booth_links.to_a.sample
    chosen_booth.click
    raise "Expected to be on an exhibitor booth page" unless on_exhibitor_booth_page?
  end


  def puts_content
    content=browser.body
    puts content
    puts "==============================================================="
  end

  def go
    home
    tasting_link = find_tasting(/Ashleemouth/)
    go_to_tasting(tasting_link)
    if on_festival_page?
      select_random_category
      select_random_booth
    end
    puts_content
    #rate_something_unrated
  end

end
