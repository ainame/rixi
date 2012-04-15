# -*- coding: undecided -*-
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rixi'
require 'open-uri'
require 'oauth2'
require 'yaml'
require_relative 'lib/rixi'
require 'sinatra/base'
require 'safariwatir' # WindowsやLinux環境では別のwatir等のgemを使う
require 'open-uri'



# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

end
scope = {
  :r_profile => true,
  :w_profile => true,
  :r_profile_status => true,
  :r_profile_gender => true,
  :r_profile_birthday => true,
  :r_profile_blood_type => true,
  :r_profile_location => true,
  :r_profile_hometown => true,
  :r_profile_about_me => true,
  :r_profile_occupation => true,
  :r_profile_interests => true,
  :r_profile_favorite_things => true,
  :r_profile_organizations => true,
  :r_voice => true,
  :w_voice => true,
  :w_share => true,
  :r_photo => true,
  :w_photo  => true,
  :r_message => true,
  :w_message => true,
  :w_diary => true,
  :r_checkin => true,
  :w_checkin => true,
  :r_updates => true
}

config = YAML.load_file("setting.yml")
M = Rixi.new( :consumer_key => config['consumer_key'],
              :consumer_secret => config['consumer_secret'],
              :redirect_uri => 'http://0.0.0.0:4567/callback',
              :scope => scope,
              :connection_opts => {:proxy => ENV["https_proxy"]},
              :raise_errors => false)

class Dummy < Sinatra::Base
  get '/' do
    "dammy page"
  end

  get '/callback' do
    "dammy page"
  end
end

Dummy.run! 

browser = Watir::Safari.new
browser.goto M.authorized_uri
sleep 1 #ブラウザ上でちゃんとページ遷移できてないとエラーとなる
browser.button(:name, "accept").click
while((code = URI.parse(browser.url).query.split("=").at(1)) == nil )

end
# codeが取得出来てるか確認
M.get_token(code)
