#!/usr/bin/env ruby
require "net/http"
require "./oauth_signer"
require "./my_keys"

def post (url, params)
  uri_object = URI.parse(url)

  signer = OAuthSigner.new(KEYS, TOKENS)
  oauth_params = signer.sign(uri_object, "POST", params)

  request = Net::HTTP::Post.new(uri_object.request_uri)
  request['Authorization'] = oauth_params.to_authorization_header
  request.set_form_data(params)

  conn = Net::HTTP.new(uri_object.host, uri_object.port)
  #conn.set_debug_output($stderr)
  conn.use_ssl = true
  response = conn.start do |conn|
    conn.request(request)
  end
  response.body
end

p(post('https://api.twitter.com/1.1/statuses/update.json', status: "Tweet内容"))
