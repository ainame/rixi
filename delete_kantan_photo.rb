# -*- coding: utf-8 -*-
puts "かんたん公開アルバムの写真を全削除します"

M ||= nil
if M.nil?
  puts "irb上でsample_safari.rbをloadしてからloadして利用して下さい。"
end

mixi = M
response = mixi.photos_in_album "@me", "@default"
response["entry"].each do |entry|
  puts "delete #{entry['id']}"
  mixi.delete_photo "@me", "@default", entry["id"]
end
puts "完了"

