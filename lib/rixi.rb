# -*- coding: utf-8 -*-
require 'oauth2'
require 'json'

class Rixi
  class APIError < StandardError
    attr_reader :response    
    def initialize(msg, response = nil)
      super(msg)
      @response = response
    end
  end
  
  attr_reader :consumer_key, :consumer_secret, :redirect_uri, :token, :client

  SITE = 'http://api.mixi-platform.com'
  AUTH_URL ='https://mixi.jp/connect_authorize.pl'
  TOKEN_URL ='https://secure.mixi-platform.com/2/token'

  def initialize(params = { })
    if params[:consumer_key] == nil && params[:consumer_secret] == nil
      raise "Rixi needs a consumer_key or consumer_secret."
    end

    @consumer_key    = params[:consumer_key]
    @consumer_secret = params[:consumer_secret]
    @redirect_uri    = params[:redirect_uri]
    @scope           = scope_to_query(params[:scope])
    @client = OAuth2::Client.new(
          @consumer_key,
          @consumer_secret,
          :site => SITE,
          :authorize_url => AUTH_URL,
          :token_url => TOKEN_URL
    )
  end
  
  #スコープ未設定の時はとりあえずプロフィールだけで
  def scope_to_query(scope)
    if scope.kind_of?(Hash)
      return scope.map {|key, value|
        key.to_s if value
      }.join(" ")
    else
      return scope || "r_profile"
    end
  end

  def authorized_uri
    @client.auth_code.authorize_url(:scope => @scope)
  end

  def get_token(code)
    @token = @client.auth_code
                    .get_token(code,
                               {:redirect_uri => @redirect_uri})
  end

  def self.api_settings
    # method name,           path for API endpoints,             http method
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
        send http_method, path % args, params
      end
    else
      define_method method_name do |params = { }|
        send http_method, path, params
      end
    end
  end

  # define_methodで定義されたメソッドは最終的に
  # これらのメソッドを呼ぶ
  def get(path, params = { })
    @token.refresh! if @token.expired?
    parse_response(@token.get(path,
                  {:mode => :query,
                   :params => params.merge({:oauth_token => @token.token})}))
  end

  def post(path, params = { })
    @token.refresh! if @token.expired?
    parse_response(@token.post(path,
                  {:mode => :body,
                   :params => params.merge({:oauth_token => @token.token})}))
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
