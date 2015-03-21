$:.unshift(File.expand_path('../lib', __FILE__))
require 'moss_return_api/server'
run MOSSReturnAPI::Server.new
