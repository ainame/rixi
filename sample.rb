# -*- coding: utf-8 -*-
require 'oauth2'
require 'sinatra'
require 'yaml'
require_relative 'lib/rixi'
enable :sessions

# コンシューマキーとシークレットを設定
# 設定ファイルにyaml形式でconsumer_keyとか書いてる
configure do
  config = YAML.load_file("setting.yml") 
  @@mixi = Rixi.new( :consumer_key => config['consumer_key'], 
                     :consumer_secret => config['consumer_secret'],
                     :site => 'https://api.mixi-platform.com',
                     :redirect_uri => 'http://0.0.0.0:4567/callback',
                     :scope => "r_profile r_voice w_voice r_updates" )
end

# セッションにトークンが存在してればAPIへアクセス
get '/' do
  if session[:login]
    res = @@mixi.people "@me", "@self"
    "ようこそ<br />#{res['entry']['displayName']}さん！"+
    "<br /><a href='/logout'>ログアウト</a>"
  else 
    "ようこそ！<br /><a href='/login'>ログイン</a>"
  end
end

# 認証ページへ飛ぶ、スコープの設定もここ
get '/login' do
  redirect @@mixi.authorized_uri
end

get '/logout' do
  session[:login] = false
  redirect '/'
end

# コールバックでアクセストークンを取得（コールバックURLを指定）
get '/callback' do  
  @@mixi.get_token(params["code"])                           
  session[:login] = true
  redirect '/'
end
