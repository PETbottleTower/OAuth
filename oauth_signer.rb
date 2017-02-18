#!/usr/bin/env ruby
require 'uri'
require 'openssl'
require 'base64'
require 'erb'

require "pry"

class OAuthParameters < Struct.new(:consumer_key, :token, :signature_method, :signature, :timestamp, :nonce)
  def to_h
    {
      oauth_consumer_key: consumer_key,
      oauth_token: token,
      oauth_signature_method: signature_method,
      oauth_signature: signature,
      oauth_timestamp: timestamp,
      oauth_nonce: nonce,
    }
  end

  def to_authorization_header
    encoded_params = to_h.map do |(key, value)|
      "#{ERB::Util.url_encode(key.to_s)}=#{ERB::Util.url_encode(value)}"
    end
    params_str = encoded_params.join(",")

    "OAuth #{params_str}"
  end
end

class OAuthSigner
  SIGNATURE_METHOD = "HMAC-SHA1"

  def initialize(keys, tokens)
    @consumer_key = keys[:consumer_key]
    @consumer_secret = keys[:consumer_secret]
    @token = tokens[:token]
    @token_secret = tokens[:token_secret]
  end


  def sign(uri_object, method, request_params)
    timestamp = Time.now.to_i.to_s
    nonce = (0...16).map{ (65 + rand(26)).chr }.join
    signature = calc_signature(uri_object, method, request_params, timestamp, nonce)

    OAuthParameters.new(@consumer_key, @token, SIGNATURE_METHOD, signature, timestamp, nonce)
  end

  def calc_basestring_uri(uri_object)
    uri_object.class.build(
      userinfo: uri_object.userinfo,
      host: uri_object.host.downcase,
      port: uri_object.port,
      path: uri_object.path,
    ).to_s
  end

  def protocol_params(timestamp, nonce)
    {
      oauth_consumer_key: @consumer_key,
      oauth_token: @token,
      oauth_signature_method: SIGNATURE_METHOD,
      oauth_timestamp: timestamp,
      oauth_nonce: nonce,
    }.to_a
  end

  def normalize_params(request_params, timestamp, nonce)
    params = protocol_params(timestamp, nonce) + request_params.to_a
    encoded = params.map {|(key, value)| [ERB::Util.url_encode(key.to_s), ERB::Util.url_encode(value)] }
    sorted = encoded.sort
    joined = sorted.map {|(key, value)| "#{key}=#{value}" }
    joined.join('&')
  end

  def calc_signature_basestring(uri_object, method, request_params, timestamp, nonce)
    basestring_uri = calc_basestring_uri(uri_object)
    normalized_params = normalize_params(request_params, timestamp, nonce)
    upcased_method = method.upcase
    encoded_basestring_uri = ERB::Util.url_encode(basestring_uri)
    encoded_params = ERB::Util.url_encode(normalized_params)
    [upcased_method, encoded_basestring_uri, encoded_params].join('&')
  end

  def calc_signature(uri_object, method, request_params, timestamp, nonce)
    signature_basestring =
      calc_signature_basestring(uri_object, method, request_params, timestamp, nonce)
    encoded_consumer_secret = ERB::Util.url_encode(@consumer_secret)
    encoded_token_secret = ERB::Util.url_encode(@token_secret)
    key = [encoded_consumer_secret, encoded_token_secret].join('&')
    Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', key, signature_basestring))
  end
end

if $0 == __FILE__ then
  require "./my_keys"
  signer = OAuthSigner.new(KEYS, TOKENS)
  oauth_params = signer.sign(
    URI.parse("https://api.twitter.com/1.1/statuses/update.json"),
    "POST",
    {
      status: "hello world",
    }
  )

  puts oauth_params.to_authorization_header

end

if $0 == __FILE__ then
  signer = OAuthSigner.new({
    consumer_key: "9djdj82h48djs9d2",
    consumer_secret: "hoge",
  }, {
    token: "kkk9d7dh3k39sjv7",
    token_secret: "foobar"
  })
  actual = signer.normalize_params([
    ["b5", "=%3D"],
    ["a3", "a"],
    ["c@", ""],
    ["a2", "r b"],
    ["c2", ""],
    ["a3", "2 q"],
  ], "137131201", "7d8f3e4a")

  #puts actual
end
