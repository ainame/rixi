# -*- coding: utf-8 -*-
require 'yaml'
require_relative 'lib/rixi'
require 'open-uri'

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

puts "open url at your browser."
puts M.authorized_uri
puts ""
print "input your code: "
code = gets.chomp

mixi = M.get_token(code)
puts "access_token"
puts mixi.token.token
puts "refresh_token"
puts mixi.token.refresh_token
puts "expires_in"
puts mixi.token.expires_in

