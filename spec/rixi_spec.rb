# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rixi do
  before do
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
    @mixi = Rixi.new( :consumer_key => config['consumer_key'],
                  :consumer_secret => config['consumer_secret'],
                  :redirect_uri => 'http://0.0.0.0:4567/callback',
                  :scope => scope)
  end

  describe "Rixi#authorize_uri" do
    it "authorize_uriの設定が正しいかどうか" do
      uri = URI.parse(@mixi.authorize_uri)
      uri.host.should == "mixi.jp"
      uri.path.should == "connect_authorize.pl"
    end

    it "consumer_key等がただしくquery内に代入されてるか" do
      uri.query.match(config['consumer_key']).should_not be_nil
      uri.query.match(config['consumer_secret']).should_not be_nil
    end


  end

end

