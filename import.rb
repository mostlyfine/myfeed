require 'active_record'
require 'opml_saw'
require 'open-uri'
require 'rss'
require_relative 'model'

filename = ARGV[0] || 'feedly.opml'
file = File.open(filename,'r')
contents = file.read
opml = OpmlSaw::Parser.new(contents)
opml.parse

opml.feeds.each do |feed|
  begin
    f = Feed.find_or_create_by(title: feed[:title], url: feed[:xml_url])
    rss = RSS::Parser.parse(f.url, false)
    rss.items.each do |item|
      title = item.title.gsub(/<.*?>/, '') rescue item.title
      link = item.link.respond_to?(:href) ? item.link.href : item.link
      article = f.articles.find_or_create_by(title: title, url: link)
      article.social!
      puts "SUCCESS #{feed[:title]} - #{title}"
    end
  rescue => ex
    puts "ERROR! #{feed[:title]} #{feed[:xml_url]}"
  end
end
