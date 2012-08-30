require 'rubygems'
require 'sinatra'
require 'dalli'
require 'cloudfiles'
require 'json'

set :expires_ttl, 21600

get '/' do
  "<img src=\"#{all_awws.sample.public_url}\" />"
end

get '/bomb/:count' do |count|
  awws = all_awws
  number_of_pictures_to_return = [awws.count, count.to_i].min
  awws.shuffle[1..number_of_pictures_to_return].map(&:public_url).to_json
end

get '/random' do
  all_awws.sample.public_url
end

private

def all_awws
  key = ENV['CF_CONTAINER']

  connect_to_memcached.fetch key, do
    container = CloudFiles::Connection.new(:username => ENV['CF_USERNAME'],
                                           :api_key  => ENV['CF_APIKEY'])
                                      .container(ENV['CF_CONTAINER'])
    container.objects().map { |obj| container.object(obj) }
  end
end

def connect_to_memcached
  Dalli::Client.new(nil, :expires_in => settings.expires_ttl)
end
