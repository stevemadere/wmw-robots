#!/usr/bin/env ruby

require 'ostruct'
require 'securerandom'

class TastingParticipant
  BASE_URL='https://staging.whatsmywine.com'
#  BASE_URL='http://localhost:3000'

  def initialize(_browser, opts = {})
    @browser = _browser
    @time_between_ratings = opts[:delay] || 5
    @num_items_to_rate = opts[:num_ratings] || 5
  end

  attr_accessor :browser, :time_between_ratings, :num_items_to_rate

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

  def go_back_to_festival
    back_to_festival_button = browser.first('a.festival-link')
    raise "cannot find the \"back to festival\" button" unless back_to_festival_button
    back_to_festival_button.click
  end

  def selected_star_rating(select_element)
    options = select_element.all('option')
    options.each do |opt|
      if opt['selected']
        return opt['value']
      end
    end
    raise "nothing was selected?!"
  end

  def option_with_value(select_element,value)
    select_element.all('option').detect { |opt| opt['value']==value}
  end

  def rate_something_unrated
    rating_selects = browser.all('select.rating-select')
    unrated_rating_selects = rating_selects.select do |node| 
      selected_star_rating(node) == '0'
    end
    if target = unrated_rating_selects.sample
      form = target.first(:xpath,".//../../..")
      slugged_wine_id = "unknown wine"
      if form['action'] =~ /wines\/([^\/]+)/
        slugged_wine_id = $1
      end
      rating = (Random.rand(5) + 1).to_s
      if opt = option_with_value(target,rating)
        opt.select_option
        puts "rated #{slugged_wine_id} #{rating} stars"
        sleep(1.0); # wait until we are fairly sure the xhr has started
      else
        raise "Could not find select option with value == #{rating}"
      end
    else
      puts "Everything was already rated?"
    end
  end


  def puts_content
    content=browser.body
    puts content
    puts "==============================================================="
  end

  def rate_some_items(num_items)
    in_festival_flow = false
    num_items.times do |i|
      sleep(time_between_ratings) unless i == 0
      if on_festival_page?
        in_festival_flow = true
        select_random_category
        select_random_booth
      end
      rate_something_unrated
      if in_festival_flow
        go_back_to_festival
      end
    end
  end

  def go
    home
    tasting_link = find_tasting(/Ashleemouth/)
    go_to_tasting(tasting_link)
    rate_some_items(num_items_to_rate)
  end

end
