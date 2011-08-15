# -*- coding: utf-8 -*-
require 'oauth2'
require 'sinatra'
require 'sinatra/reloader'
require 'httparty'
require 'yaml'
require 'hashie'
require 'json'
require 'pp'
require_relative 'lib/mixi'
enable :sessions

# コンシューマキーとシークレットを設定
configure do
  config = YAML.load_file("setting.yml") 
  @@mixi = Mixi.new( :consumer_key => config['consumer_key'], 
                     :consumer_secret => config['consumer_secret'],
                     :site => 'https://api.mixi-platform.com',
                     :redirect_uri => 'http://0.0.0.0:4567/callback',
                     :scope => "r_profile r_voice w_voice r_updates" )
end

# セッションにトークンが存在してればAPIへアクセス
get '/' do
  if session[:token]
    #response = HTTParty.get('http://api.mixi-platform.com/2/people/@me/@self',
    #:query => {:oauth_token => session[:token]})
    #d = @@token.get("/2/people/@me/@self?oauth_token="+session[:token])   
    #pp json = Hashie::Mash.new(JSON.parse(d.body))
    pp @@mixi.people "@me", "@self"
    #"ようこそ<br />{json.response['entry']['displayName']}さん！"+
    #"<br /><a href='/logout'>ログアウト</a>"
  else 
    "ようこそ！<br /><a href='/login'>ログイン</a>"
  end
end

# 認証ページへ飛ぶ、スコープの設定もここ
get '/login' do
  redirect @@mixi.authorized_uri
end

get '/logout' do
  session[:token] = nil
  session[:ref_token] = nil

  redirect '/'
end

# コールバックでアクセストークンを取得（コールバックURLを指定）
get '/callback' do  
  @@token = @@mixi.get_token(params["code"])                           
  session[:ref_token] = @@token.refresh_token.to_s
  session[:token] = @@token.token.to_s

  redirect '/'
end
