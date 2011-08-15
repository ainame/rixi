# -*- coding: utf-8 -*-
require 'oauth2'
require 'json'
require 'hashie'
require 'cgi'

class Rixi
  class APIError < StandardError
    attr_reader :response    
    def initialize(msg, response = nil)
      super(msg)
      @response = response
    end
  end
  
  attr_accessor :consumer_key, :consumer_secret, :redirect_uri

  def initialize(params = { })
    @consumer_key    = params[:consumer_key]
    @consumer_secret = params[:consumer_secret]
    @redirect_uri    = params[:redirect_uri]
    @scope = params[:scope] || "r_profile"
    @client = OAuth2::Client.new(
          @consumer_key,
          @consumer_secret,
          :site => 'http://api.mixi-platform.com',
          :authorize_url =>'https://mixi.jp/connect_authorize.pl',
          :token_url =>'https://secure.mixi-platform.com/2/token'
    )
  end
  
  def set_scope(scope)
    @scope ||= scope
  end

  def authorized_uri
    @client.auth_code.authorize_url(:scope => @scope)
  end

  def get_token(code)
    @token = @client.auth_code.get_token(code,
                                         {:redirect_uri => @redirect_uri})
  end

  def self.api_settings
    # method name,      path for API,         http method
     "people                   /2/people/%s/%s                           get
      user_timeline            /2/voice/statuses/%s/user_timeline        get
      friends_timeline         /2/voice/statuses/%s/user_timeline        get
      show_status              /2/voice/statuses/show/%s                 get
      update_status            /2/voice/statuses/update                  post
      delete_status            /2/voice/statuses/destroy/%s              post
      create_reply             /2/voice/statuses/replies/create/%s       post
      delete_reply             /2/voice/replies/destroy/%s/%s            post
      show_favorites_on_voice  /2/voice/favorites/show/%s                get
      favorite_to_voice        /2/voice/favorites/create/%s              post
      delete_favorite_to_voice /2/voice/favorites/destory/%s/%s          post
    ".strip.split("\n").map {|l| l.strip.split(/\s+/)}
  end

  api_settings.each do |api|
    method_name, path, http_method = *api
    http_method ||= 'get'
    if /%s/ =~ path
      define_method method_name do |*args|
        params = args.last.kind_of?(Hash) ? args.pop : { }
        params.merge!({:oauth_token => @token.token})
        send http_method, path % args, params
      end
    else
      define_method method_name do |params = { }|
        send http_method, path, params
      end
    end
  end

  # define_methodでgetかpostにsendされてるので
  # これらのメソッドが呼ばれる
  def get(path, params = { })
    @token.refresh! if @token.expired?
    parse_response(@token.get(path + '?' + parse_params(params)))
  end

  def post(path, params = { })
    @token.refresh! if @token.expired?
    parse_response(@token.post(path, stringify_params(params)))
  end

  def parse_params(params = { })
    params.map { |k, v| k.to_s + '=' + CGI.escape(v.to_s)}.join('&')
  end

  def stringify_params(params = { })
    params.inject({ }) do |h, (k, v)|
      h[k.to_s] = v.to_s
      h
    end
  end

  def parse_response(res)
    res = res.response.env
    case res[:status].to_i
    when 400...600
      raise APIError.new("API Error", res)
    else
      JSON.parse(res[:body])
    end
  end
  
end
