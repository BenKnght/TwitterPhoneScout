class GuestsController < ApplicationController

# This process isn't used anymore because I now use the omniauth gem
# The code below manually requests indivual user access tokens from Twitter

=begin
	def new

		cSec = "dnRZW4IChVL4bNgBSUE0C2ees8sN7PWvfUg3iQcVl8Iun8g7WG"
		aSec = "VLVo41nSMLMCuVU3qfpHLkYzb4jgdtUFQSp0wUYD2Iw2X"

		range = [*'0'..'9',*'A'..'Z',*'a'..'z']
		randString = Array.new(32){ range.sample }.join

		baseUrl = "https://api.twitter.com/1.1/oauth/request_token"
		method = "POST"

		options = {}
		options["oauth_callback"] = "http://localhost:5000/users/new"
        options["oauth_consumer_key"] = "ddn7p7gNZGvO5193GGilWTeW4"
        options["oauth_nonce"] = randString
        options["oauth_signature_method"] = "HMAC-SHA1"
        options["oauth_timestamp"] = Time.now.to_i.to_s
        options["oauth_version"] = "1.0"

        prepArray = []
        options.each do |key, val|
        	prepArray.push(CGI.escape(key) + "=" + CGI.escape(val))
        end

        paramString = ""
        prepArray.sort!

        prepArray[1..-1].each do |x|
        	paramString << ("&" + x)
        end

        sigBaseString = method + "&" + CGI.escape(baseUrl) + "&" + CGI.escape(paramString)

        signingKey = CGI.escape(cSec) + "&" + CGI.escape(aSec)

		digest = OpenSSL::Digest.new("sha1")
		hmac = OpenSSL::HMAC.digest(digest, signingKey, sigBaseString)
		signature = Base64.strict_encode64(hmac)

		options["oauth_signature"] = signature

		RestClient.post("https://api.twitter.com/oauth/request_token", options) do |response, request, result|

		    $token =  (JSON.parse(response))["access_token"]

		end

	end
=end 


end
