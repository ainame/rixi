# -*- coding: utf-8 -*-
module Rixi
  module HTTPExtension
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # 画像 は params[:image], タイトルは params[:title]で渡す
      # 画像はバイナリ文字列で渡す
      def post_image(path, params = { })
        path += "?title="+ CGI.escape(params[:title]) if params[:title]
        self.post(path,{
                      :headers => {
                        :content_type  => "image/jpeg",
                        :content_length => params[:image].size.to_s,
                      },:body   => params[:image]})
      end

      # params[:json]はハッシュで渡して関数内でJSON化する
      def post_json(path, params = { })
        self.post(path,{
                      :headers => {
                        :content_type  => "application/json; charset=utf-8",
                        :content_length => params[:json].size.to_s
                      },:body   => params[:json]})
      end

      # JSON形式＋写真を投稿することが可能なAPIについて
      def post_multipart(path, params ={ })
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

        self.post(path,{
                      :headers => {
                        :content_type  => content_type,
                        :content_length => body.size.to_s
                      },
                      :body => body})
      end
    end
  end
end
