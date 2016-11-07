require 'rubygems'
require 'sinatra'
require 'webrick'
require 'rest-client'
require 'octokit'
require 'yaml'
require 'logger'
require 'digest/sha1'
require 'webrick/httpproxy'
require "rack/reverse_proxy"

set :port, 8999
set :environment, :production
set :server, 'webrick'
enable :sessions
set :timeout, 120

APP_ROOT = File.expand_path './', File.dirname(__FILE__)

skeleton = YAML::load_file(APP_ROOT+'/config/skeleton.yaml')
namaspaces_file = YAML::load_file(APP_ROOT+'/config/namespaces.yaml')
namespaces = namaspaces_file['namespaces']

use Rack::ReverseProxy do
  namespaces.each do |namespace|
    skeleton['NAMESPACE'].each do |service|
      service_name = service['service']
      port = service['port'].to_s
      #reverse_proxy /^\/documentation\/?(.*)$/, 'http://localhost/$1'
      reverse_proxy /^\/#{namespace}\/#{service_name}\/?(.*)$/, 'http://'+service_name+"."+namespace+':'+port+'/$1'
    end
  end
end
