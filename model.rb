require 'active_record'
require 'open-uri'
require 'json'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'development.sqlite3')

# ActiveRecord::Migration.create_table :feeds do |f|
#   f.string :title
#   f.string :url
#   f.timestamp :created_at, null: false
# end

# ActiveRecord::Migration.create_table :articles do |f|
#   f.integer :feed_id
#   f.string :title
#   f.string :url
#   f.integer :facebook, default: 0, null: false
#   f.integer :twitter, default: 0, null: false
#   f.integer :hatena, default: 0, null: false
#   f.integer :pintarest, default: 0, null: false
#   f.timestamp :created_at, null: false
# end

class Feed < ActiveRecord::Base
  has_many :articles
end

class Article < ActiveRecord::Base
  belongs_to :feed

  def facebook!
    if self.facebook.blank?
      json = JSON.parse(open("http://graph.facebook.com/?id=#{url}").read)
      self.update_attributes(facebook: json['shares'] || 0)
    end
  rescue
  end

  def twitter!
    if self.twitter.blank?
      json = JSON.parse(open("http://urls.api.twitter.com/1/urls/count.json?url=#{url}").read)
      self.update_attributes(twitter: json['count'] || 0)
    end
  rescue
  end

  def hatena!
    if self.hatena.blank?
      json = open("http://api.b.st-hatena.com/entry.count?url=#{url}").read
      self.update_attributes(hatena: json.blank? ? 0 : json)
    end
  rescue
  end

  def pintarest!
    if self.pintarest.blank?
      jsonp = open("http://api.pinterest.com/v1/urls/count.json?url=#{url}").read
      pin = JSON.parse(jsonp[/{.+}/])
      self.update_attributes(pintarest: pin['count'] || 0)
    end
  rescue
  end

  def social!
    facebook!
    twitter!
    hatena!
    pintarest!
  end
end
