# -*- coding: utf-8 -*-
require 'oauth2'
require 'yaml'
require_relative 'lib/rixi'
require 'safariwatir' # WindowsやLinux環境では別のwatir等のgemを使う
require 'open-uri'

#
# irbで各種メソッドを試したい時に使うツール
# usage:
# 1. Sinatra等で簡単にcallbackに指定するURLに対応するページを
# 作成して起動しておく
# --app.rb--
# require 'sinatra'
# get '/callback' do 
#   "hoge"
# end
# ----------
# $ ruby app.rb
#
# 2. 次にirbを立ち上げてこのファイルをloadする
# $ irb
# ruby-1.9.2-p180 :001 > load "sample_safari.rb" 
#
# 3.各種操作の実行が終わるまで暫く待つ。ブラウザ上に、
# Sinatraのcallback画面表示されたらcodeが取得できる。
# 
# 4.irb上で定数の「M」にrixiのインスタンスが代入されているので
# 定数Mを通して各種APIを叩くメソッドを試す。
# 例：
# ruby-1.9.2-p180 :002 > M.people "@me", "@self"
#


# scopeはハッシュ形式でも文字列を自前で連結してもOK
scope = { 
  :r_profile => true,
  :w_profile => true,
  :r_profile_status => true,
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
              :scope => scope)

# scopeはハッシュ形式でも文字列を自前で連結してもOK
browser.goto M.authorized_uri
sleep 1 #ブラウザ上でちゃんとページ遷移できてないとエラーとなる
browser.button(:name, "accept").click
sleep 1
code = URI.parse(browser.url).query.split("=").at(1)
# codeが取得出来てるか確認
pp code 

M.get_token(code)
