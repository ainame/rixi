# -*- coding: utf-8 -*-
require 'oauth2'
require 'yaml'
require_relative 'lib/rixi'
#テスト用
require 'safariwatir'
require 'open-uri'

#ブラウザ初期化
browser = Watir::Safari.new

config = YAML.load_file("setting.yml") 
M = Rixi.new( :consumer_key => config['consumer_key'], 
              :consumer_secret => config['consumer_secret'],
              :redirect_uri => 'http://0.0.0.0:4567/callback',
              :scope => "r_profile w_profile r_profile_status r_voice w_voice w_share r_photo w_photo r_message w_message w_diary r_checkin w_checkin r_updates " 
              )

browser.goto M.authorized_uri
sleep 1
browser.button(:name, "accept").click
sleep 1
code = URI.parse(browser.url).query.split("=").at(1)
M.get_token(code)
