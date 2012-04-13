class Rixi
  module Config
    SITE = 'http://api.mixi-platform.com'
    AUTH_URL ='https://mixi.jp/connect_authorize.pl'
    DEFAULT_ENDPOINT ='https://secure.mixi-platform.com/2/token'
    
    VALID_OPTION = { 
      :site,
      :auth_url,
      :endpoint
    }.freeze

    attr_accessor *VALID_OPTION

    def self.extended(base)
      base.reset
    end

    def reset
      self.site = SITE
      self.auth_url = AUTH_URL
      self.endpoint = DEFAULT_ENDPOINT
    end

    def configure
      yield self
      return self
    end

  end
end
