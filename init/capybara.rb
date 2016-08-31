require 'capybara/poltergeist'

IE='Mozilla/5.0 (compatible, MSIE 11, Windows NT 6.3; Trident/7.0;  rv:11.0) like Gecko'
# Configure Poltergeist to not blow up on websites with js errors aka every website with js
# See more options at https://github.com/teampoltergeist/poltergeist#customization
Capybara.register_driver :poltergeist do |app|
  pg = Capybara::Poltergeist::Driver.new(app, js_errors: false)
  pg.headers = { "User-Agent" => IE }
  pg
end

# Configure Capybara to use Poltergeist as the driver
Capybara.default_driver = :poltergeist

