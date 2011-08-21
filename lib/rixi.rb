# -*- coding: utf-8 -*-
require 'cgi'
require 'oauth2'
require 'json'

# monkey patch
module OAuth2
  class Client
    def get_token(params)
      opts = { :raise_errors => true, :parse => params.delete(:parse)}
      if options[:token_method] == :post
        opts[:body] = params
        opts[:headers] =  { 'Content-Type' => 'application/x-www-form-urlencoded'}
      else
        opts[:params] = params
      end
      response = request(options[:token_method], token_url, opts)
      raise Error.new(response) unless response.parsed.is_a?(Hash) && response.parsed['access_token']

      # デフォルトではヘッダーでのAccessToken指定が出来ないため
      # modeとheader_formatを追加
      AccessToken.new(self, response.parsed.delete("access_token"), 
                      :mode => :header,
                      :header_format => "OAuth %s")
    end
  end
end

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
    
    @consumer_key    = params.delete :consumer_key
    @consumer_secret = params.delete :consumer_secret
    @redirect_uri    = params.delete :redirect_uri
    @scope           = scope_to_query(params.delete(:scope))
    
    params.merge!({
      :site => SITE,
      :authorize_url => AUTH_URL,
      :token_url => TOKEN_URL    
    })
    @client = OAuth2::Client.new(
          @consumer_key,
          @consumer_secret,
          params
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
                    .get_token(code,{:redirect_uri => @redirect_uri})
  end
  
  #
  # 手抜き実装のため、長いメソッド名の乱立で非常に汚いです
  # メソッド名は適当なので好きなように変えて使ってください
  # %s の部分が各種メソッドの引数になります
  # 
  # 次期バージョンが出来るとするならAPIの種類毎に
  # モジュールに切り分けて実装したいです。
  #
  # 注：%o は省略可能なpathを表現するために使ってます
  # 例えば、友人のつぶやき一覧の取得をするAPIは以下で、
  # /2/voice/statuses/friends_timeline/[Group-ID]?since_id=[つぶやきのID]
  # Group-IDはpathにも含まれますが省略可能です
  # そのような場合は、最後の引数のハッシュで:optional_pathのキーで
  # 指定するとして、:optional_pathが存在しなければAPIのパスから
  # 省略することとします。
  #
  # 注2：mixiチェック用API /2/share はPOSTメソッドでリクエストする際に、
  # データをJSON形式で与えるため、未実装です。
  #
  # 注3：DiaryAPIもmultipart/form-data形式として投稿しなければならないため
  # 現状、未実装です
  #
  #
  def self.api_settings
    # method name,           path for API endpoints,             http method
     "people                /2/people/%s/%s                           get
      search_people         /2/search/people/%s                       get
      updates               /2/updates/%s/%s                          get
      user_timeline         /2/voice/statuses/%s/user_timeline        get
      friends_timeline      /2/voice/statuses/%s/friends_timeline/%o  get
      show_status           /2/voice/statuses/show/%s                 get
      show_favorites        /2/voice/favorites/show/%s                get
      update_status         /2/voice/statuses/update                  post
      delete_status         /2/voice/statuses/destroy/%s              post
      create_replies        /2/voice/statuses/replies/create/%s       post
      delete_replies        /2/voice/replies/destroy/%s/%s            post
      create_favorite       /2/voice/favorites/create/%s              post
      delete_favorite       /2/voice/favorites/destory/%s/%s          post
      albums                /2/photo/albums/%s/@self/%o               get
      recent_album          /2/photo/albums/%s/%s                     get
      photos_in_album       /2/photo/mediaItems/%s/@self/%s/%o        get
      recent_photos         /2/photo/mediaItems/%s/%o 　　　　        get
      comments_album        /2/photo/comments/albums/%s/@self/%s      get
      comments_photo        /2/photo/comments/mediaItems/%s/@self/%s/%s  get
      favorites_photo       /2/phoho/favorites/mediaItems/%s/@self/%s/%s get
      create_album          /2/photo/albums/%s/@self                  post
      delete_album          /2/photo/albums/%s/@self/%s               delete
      create_comment_album  /2/photo/comments/albums/%s/@self/%s      post
      delete_comment_album  /2/photo/comments/albums/%s/@self/%s/%s   delete
      upload_photo          /2/photo/mediaItems/%s/@self/%s           post_image
      delete_photo          /2/photo/mediaItems/%s/@self/%s/%s        delete
      create_comment_photo  /2/photo/comments/mediaItems/%s/@self/%s/%s/ delete
      create_favorite_photo /2/photo/favorites/mediaItems/%s/@self/%s/%s/ post
      delete_favorite_photo /2/photo/favorites/mediaItems/%s/@self/%s/%s/ delete
      spot                  /2/spots/%s                               get
　　  search_spot           /2/search/spots                           get
      spots_list            /2/spots/%s/@self                         get
      create_myspot         /2/spots/%s/@self                         post
      delete_myspot         /2/spots/%s/@self                         delete
      get_checkins          /2/checkins/%s/%s                         get
      get_checkin           /2/checkins/%s/@self/%s                   get 
      checkin               /2/checkins/%s                            post
      checkin_with_photo    /2/checkins/%s                            post_spot
      messages_inbox        /2/messages/%s/@inbox/%o                  get
      messages_outbox       /2/messages/%s/@outbox/%o                 get
      create_message        /2/messages/%s/@self/@outbox              post
      read_message          /2/messages/%s/@self/@inbox/%s            put
      delete_inbox          /2/messages/%s/@self/@inbox/%s            put
      delete_outbox         /2/messages/%s/@self/@outbox/%s           delete
      people_images         /2/people/images/%s/@self/%o              get
      create_people_image   /2/people/images/%s/@self                 post
      set_people_image      /2/people/images/%s/@self/%s              put
      delete_people_image   /2/people/images/%s/@self/%s              delete
    ".strip.split("\n").map {|l| l.strip.split(/\s+/)}
  end
 
  api_settings.each do |api|
    method_name, path, http_method = *api
    http_method ||= 'get'
    if /%s/ =~ path
      define_method method_name do |*args|
        params = args.last.kind_of?(Hash) ? args.pop : { }
        if /%o/ =~ path
          if params.key? :optional_path
            path.sub!("%o",params[:optional_path].to_s)
          else
            path.sub!("/%o","")
          end
        end
        __send__ http_method, path % args, params
      end
    else
      define_method method_name do |params = { }|
        __send__ http_method, path, params
      end
    end
  end

  # define_methodで定義されたメソッドは最終的に
  # これらのメソッドを呼ぶ
  def get(path, params = { })
    extend_expire()
    parse_response(@token.get(path, :params => params))
  end

  def post(path, params = { })
    extend_expire()
    parse_response(@token.post(path,:params => params))
  end

  # 画像 は params[:image], タイトルは params[:title]で渡す
  def post_image(path, params = { })
    extend_expire()
    path += "?title="+ CGI.escape(params[:title]) if params[:title]
    parse_response(@token.post(path,
                               {
                                 :headers => {
                                   :content_type  => "image/jpeg",
                                   :content_length => params[:image].size.to_s,
                                 },
                                 :body   => params[:image].read
                               }))
  end

  # 写真付きspotの投稿
  def post_spot(path, params = { })
    extend_expire()
    path += "?title="+ CGI.escape(params[:title]) if params[:title]
    parse_response(@token.post(path,
                               { :headers => {
                                   :content_type  => "multipart/form-data",
                                   :content_length => params[:image].size.to_s,
                                 },
                                 :body   => "request=" + params[:spot].to_json +
                                   "&photo=" + params[:image].read
                                 }))
  end

  def delete(path, params = { })
    extend_expire()
    @token.delete(path, :params => params).response.env[:status].to_s
  end

  def put(path, params = { })
    extend_expire()
    parse_response(@token.put(path, :params => params))
  end

  # OAuth2::AccessTokenの仕様上破壊的代入が出来ないため...
  def extend_expire
    if @token.expired?
      @token = @token.refresh! 
    end
  end

  # mixiボイスの投稿を楽にするため
  def voice_update(status)
    voice_statuses_update(:statsus => status)
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
