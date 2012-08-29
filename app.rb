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
  cache = connect_to_memcached

  cached_value = cache.get key

  if cached_value.nil?
    puts "Cached value not found. Issuing Cloud Files API request."
    container = connect_to_cloud_files.container(ENV['CF_CONTAINER'])
    result = container.objects().map { |obj| container.object(obj) }

    cache.set key, result
  else
    result = cached_value
  end

  return result
end

def connect_to_cloud_files
  CloudFiles::Connection.new(:username => ENV['CF_USERNAME'],
                             :api_key => ENV['CF_APIKEY'])
end

def connect_to_memcached
  Dalli::Client.new(nil, :expires_in => settings.expires_ttl)
end
