#!/usr/bin/env ruby
require "net/http"
require "erb"
include ERB::Util

Class HTTP
def initialize
end

def post (url)
  url = URI.parse(url)
  http = NET::HTTP.new(url, 80)
  request = NET::HTTP::GET.new(url.request_uri)

  req = authorization_header.dup

  NET::HTTP.start(url.host, url.port) do |http|
    http.request(req["auth_header"])
  end
end

def authorization_header (oauth_consumer_key, oauth_token, oauth_signature_method, oauth_signature, oauth_timestamp, oauth_nonce)
  =begin
  $oauth_consumer_key
  $oauth_token
  $oauth_signature_method
  $oauth_signature
  $oauth_timestamp
  $oauth_nonce
  $oauth_version
  =end

  auth_scheme = "Authorization: OAuth "
  oauth_consumer_key = "oauth_consumer_key=\"" + url_encode(oauth_consumer_key) + "\","
  oauth_token = "oauth_token=\"" + url_encode(oauth_token) + "\","
  oauth_signature_method = "oauth_signature_method=\"" + url_encode(oauth_signature_method) + "\","
  oauth_signature = "oauth_signature=\"" + url_encode(oauth_signature) + "\","
  oauth_timestamp = "oauth_timestamp=\"" + url_encode(oauth_timestamp) + "\","
  oauth_nonce = "oauth_nonce=\"" + url_encode(oauth_nonce) + "\""

  header["auth_header"] = auth_scheme + oauth_consumer_key + oauth_token + oauth_signature_method + oauth_signature + oauth_timestamp + oauth_nonce
end

end
