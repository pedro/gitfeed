require 'rubygems'
require 'sinatra'

repo = ARGV[0] || raise("Specify the repo location in the first arg. ie ruby gitrepo.rb /git/myrepo")
repo = repo.gsub(/\/$/, '')

raise "Could not find a fit repo in #{repo}" unless File.exists?("#{repo}/objects")

get "*" do
  file = request.env['REQUEST_URI'][1..-1]
  log  = `cd #{repo} && git log stack3 -n5 --pretty=format:"%h|%an|%aD|%s" -- #{file}`
  logs = log.split("\n").map { |l| l.split('|', 4) }
  throw(:halt, [404, "Path not found: #{file}"]) if logs.empty?

  builder do |xml|
    xml.instruct! :xml, :version => '1.0'
    xml.rss :version => '2.0' do
      xml.channel do
        xml.title "Git Feed for #{repo}/#{file}"
        logs.each do |rev, author, date, message|
          xml.item do
            xml.title "#{rev} by #{author}"
            xml.pubDate date
            xml.description message
          end
        end
      end
    end
  end
end
