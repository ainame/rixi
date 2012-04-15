# -*- coding: utf-8 -*-

module Rixi
  # module Rixi::HTTPRequestExtension
  #
  # mixi Graph APIに合わせてOAuth2::AccessTokenの
  # HTTP Requestのメソッドを拡張したメソッドを定義してます．
  module HTTPRequestExtension
    # 画像 は params[:image], タイトルは params[:title]で渡す
    # 画像はバイナリ文字列で渡す
    def post_image(path, params = { }, &block)
      path += "?title="+ CGI.escape(params[:title]) if params[:title]
      post(path,{
             :headers => {
               :content_type  => "image/jpeg",
               :content_length => params[:image].size.to_s,
             },:body   => params[:image]}, &block)
    end

    # params[:json]はハッシュで渡して関数内でJSON化する
    def post_json(path, params = { }, &block)
      post(path,{
             :headers => {
               :content_type  => "application/json; charset=utf-8",
               :content_length => params[:json].size.to_s
             },:body   => params[:json]}, &block)
    end

    # JSON形式＋写真を投稿することが可能なAPIについて
    def post_multipart(path, params ={ }, &block)
      if params[:image]
        now = Time.now.strftime("%Y%m%d%H%M%S")
        content_type = "multipart/form-data; boundary=boundary#{now}"
        body  = application_json(now,params[:json])
        body << attach_photos(now,params[:image])
        body << end_boundary(now)
      else
        content_type = "application/json"
        body = params[:json].to_json
      end

      post(path,{
             :headers => {
               :content_type  => content_type,
               :content_length => body.size.to_s
             },
             :body => body}, &block)
    end

    # build request body
    def application_json(time,json)
      return <<-"EOF".force_encoding("UTF-8")
--boundary#{time}\r
Content-Disposition: form-data; name="request"\r
Content-Type: application/json\r
\r
#{json.to_json}\r
EOF
    end

    def attach_photos(time, imgs)
      if imgs.instance_of?(Array)
        count = 1
      else
        count = ""
        imgs = [imgs]
      end

      attach = ""
      imgs.each do |img|
        tmp = <<"IMAGE".force_encoding("UTF-8")
--boundary#{time}\r
Content-Disposition: form-data; name="photo#{count}"; filename="#{time+count.to_s}.jpg"\r
Content-Type: image/jpeg\r
\r
#{img}\r
IMAGE
        count+=1 if count != ""
        attach << tmp
      end
      attach
    end

    def end_boundary(time)
      "--boundary#{time}--"
    end

  end
end

