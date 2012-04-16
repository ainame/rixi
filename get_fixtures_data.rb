# -*- coding: utf-8 -*-
require 'yaml'
require_relative 'lib/rixi'
require 'open-uri'
require 'pp'
require 'pry'

scope = {
  :r_profile => true,
  :w_profile => true,
  :r_profile_status => true,
  :r_profile_gender => true,
  :r_profile_birthday => true,
  :r_profile_blood_type => true,
  :r_profile_location => true,
  :r_profile_hometown => true,
  :r_profile_about_me => true,
  :r_profile_occupation => true,
  :r_profile_interests => true,
  :r_profile_favorite_things => true,
  :r_profile_organizations => true,
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
m = Rixi.new( :consumer_key => config['consumer_key'],
              :consumer_secret => config['consumer_secret'],
              :redirect_uri => 'http://0.0.0.0:4567/callback',
              :scope => scope,
              :connection_opts => {:proxy => ENV["https_proxy"]},
              :raise_errors => false)
mixi = m.set_token(config['access_token'], config['refresh_token'], 1)
mixi.instance_eval do 
  @token = @token.refresh!
end

def methods_data
  # method name,           path for API endpoints,             http method
  "people                /2/people/%s/%s                           get
      search_people         /2/search/people/%s                       get
      updates               /2/updates/%s/%s                          get
      user_timeline         /2/voice/statuses/%s/user_timeline        get
      friends_timeline      /2/voice/statuses/friends_timeline/%o     get
      show_status           /2/voice/statuses/show/%s                 get
      show_favorites        /2/voice/favorites/show/%s                get
      update_status         /2/voice/statuses/update                  post
      delete_status         /2/voice/statuses/destroy/%s              post
      create_replies        /2/voice/statuses/replies/create/%s       post
      delete_replies        /2/voice/replies/destroy/%s/%s            post
      create_favorite       /2/voice/favorites/create/%s              post
      delete_favorite       /2/voice/favorites/destory/%s/%s          post
      share                 /2/share                                  post_json
      albums                /2/photo/albums/%s/@self/%o               get
      recent_album          /2/photo/albums/%s/%s                     get
      photos_in_album       /2/photo/mediaItems/%s/@self/%s/%o        get
      recent_photos         /2/photo/mediaItems/%s/%o 　　　　        get
      comments_album        /2/photo/comments/albums/%s/@self/%s      get
      comments_photo        /2/photo/comments/mediaItems/%s/@self/%s/%s  get
      favorites_photo       /2/phoho/favorites/mediaItems/%s/@self/%s/%s get
      create_album          /2/photo/albums/%s/@self                  post_json
      delete_album          /2/photo/albums/%s/@self/%s               delete
      create_comment_album  /2/photo/comments/albums/%s/@self/%s      post_json
      delete_comment_album  /2/photo/comments/albums/%s/@self/%s/%s   delete
      upload_photo          /2/photo/mediaItems/%s/@self/%s           post_image
      delete_photo          /2/photo/mediaItems/%s/@self/%s/%s        delete
      create_comment_photo  /2/photo/comments/mediaItems/%s/@self/%s/%s/ post_json
      delete_comment_photo  /2/photo/comments/mediaItems/%s/@self/%s/%s/ delete
      create_favorite_photo /2/photo/favorites/mediaItems/%s/@self/%s/%s/ post
      delete_favorite_photo /2/photo/favorites/mediaItems/%s/@self/%s/%s/ delete
      spot                  /2/spots/%s                               get
      search_spot           /2/search/spots                           get
      spots_list            /2/spots/%s/@self                         get
      create_myspot         /2/spots/%s/@self                         post
      delete_myspot         /2/spots/%s/@self                         delete
      get_checkins          /2/checkins/%s/%s                         get
      get_checkin           /2/checkins/%s/@self/%s                   get
      checkin               /2/checkins/%s                            post_multipart
      checkin_with_photo    /2/checkins/%s                            post_multipart
      diary                 /2/diary/articles/@me/@self               post_multipart
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

#
# テストしたい引数の組み合わせを配列の中に書いていく
#
args_list = {
  people: [["@me", "@self"]],
  search_people: [["@all", {:q => "shogibu@hotmail.com"}]],
  updates: [["@me", "@self"]],
  user_timeline: [["@me"]],
  friends_timeline: [["@me"]],
  show_status: [],
  show_favorites: [],
  update_status: [],
  delete_status: [],
  create_replies: [],
  delete_replies: [],
  create_favorite: [],
  delete_favorite: [],
  share: [],
  albums: [],
  recent_album: [],
  photos_in_album: [],
  recent_photos: [],
  comments_album: [],
  comments_photo: [],
  favorites_photo: [],
  create_album: [],
  delete_album: [],
  create_comment_album: [],
  delete_comment_album: [],
  upload_photo: [],
  delete_photo: [],
  create_comment_photo: [],
  delete_comment_photo: [],
  create_favorite_photo: [],
  delete_favorite_photo: [],
  spot: [],
  search_spot: [],
  spots_list: [],
  create_myspot: [],
  delete_myspot: [],
  get_checkins: [],
  get_checkin: [],
  checkin: [],
  checkin_with_photo: [],
  diary: [],
  messages_inbox: [],
  messages_outbox: [],
  create_message: [],
  read_message: [],
  delete_inbox: [],
  delete_outbox: [],
  people_images: [],
  create_people_image: [],
  set_people_image: [],
  delete_people_image: [],
}

def args_to_name (args)
  params = args.last.kind_of?(Hash) ? args.pop : { }
  name = args.map{|x| x.sub("@","")}.join("_")
  !params.empty? ? begin
    args.push(params)
    name += "_" + params.to_a.join("_")    
  end : { }
  name
end

args_list.each do |k, v|
  `mkdir -p fixtures/#{k.to_s}/`
  p k
  v.each do |args|
    file_name = args_to_name(args)
    File.open("fixtures/#{k.to_s}/#{file_name}.json","w+") do |file|
      p *args
      if data = (mixi.send k, *args)
        file.puts data 
      end
    end
  end
end
