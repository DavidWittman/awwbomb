require 'rubygems'
require 'cloudfiles'
require 'json'
require 'optparse'
require 'patron'
require 'uri'

def url_to_cloudfiles(url, cf, container_name)
  uri_pieces = URI(url)
  filename = uri_pieces.path.delete '/? '
  
  # Download
  dl = Patron::Session.new
  dl.timeout = 30
  dl.base_url = uri_pieces.scheme + "://" + uri_pieces.host
  dl.headers['User-Agent'] = 'awwbomb/1.0'
  print 'Downloading ' + url + '...'
  STDOUT.flush
  dlresp = dl.get_file(uri_pieces.path, filename)
  print 'complete...Uploading...'
  STDOUT.flush

  # Upload
  container = cf.container(container_name)
  object = container.create_object filename, false
  object.write(open(filename))
  puts 'complete.'
  
  File.delete(filename)
end

def get_imgurls_from_reddit(subreddit)
  urls = []
  sess = Patron::Session.new
  sess.timeout = 30
  sess.base_url = "http://www.reddit.com"
  sess.headers['User-Agent'] = 'awwbomb/1.0'
  resp = sess.get("/r/" + subreddit + ".json")
  if resp.status == 200
    result = JSON.parse(resp.body)
    result['data']['children'].each do |entry|
      if entry['data']['url'].include? "http://i.imgur.com/"
        urls << entry['data']['url']
      end
    end
  end
  
  return urls
end

def main()
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: upload.rb --username myusername --apikey ABC123 --container mycontainer"

    opts.on("-u", "--username USERNAME", "OpenStack username") do |username|
      options[:username] = username
    end

    opts.on("-k", "--apikey APIKEY", "OpenStack API key") do |apikey|
      options[:apikey] = apikey
    end
  
    opts.on("-c", "--container CONTAINER", "OpenStack Swift container name") do |container|
      options[:container] = container
    end
  end.parse!
  
  ["username", "apikey", "container"].each do |arg|
    raise OptionParser::MissingArgument if options[:"#{arg}"].nil? 
  end

  urls = get_imgurls_from_reddit('aww')
  cf = CloudFiles::Connection.new(:username => options[:username], :api_key => options[:apikey])
  container_name = options[:container]

  # Make the container if it doesn't exit
  unless cf.containers.include?(container_name)
    cf.create_container(container_name)
  end

  # Download each file and then upload it into Cloud Files
  container = cf.container(container_name)
  urls.each do |url|
    url_to_cloudfiles(url, cf, container_name)
  end
  
  # Mark the container "public" so that http(s) can be made directory to the files
  if !container.make_public()
    puts "Error: Cannot make " + container_name + " a public container."
  else
    puts "Public URL for " + container_name + ": " + container.cdn_url
  end
end

main()
