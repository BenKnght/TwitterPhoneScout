require 'twitter'
require 'rubygems'
require 'base64'
require 'rest-client'
require 'json'
require 'twilio-ruby'

#Twilio Credentials
twilSID = "AC2917d501d6f696a7be030dab47b8c3e7"
twilTok = "898644b67dd18bd1e8dcd8aa6f942db6"

$lookup_client = Twilio::REST::LookupsClient.new twilSID, twilTok


#These are Phone Scout specific access credentials -- DONT CHANGE
cKey      = "ddn7p7gNZGvO5193GGilWTeW4"
cSec      = "dnRZW4IChVL4bNgBSUE0C2ees8sN7PWvfUg3iQcVl8Iun8g7WG"
aTok      = "941850966-k9gNxw8TmeXjunOSIpnqlWb9fiTaIhY1KfB5lvzG"
aSec 	    = "VLVo41nSMLMCuVU3qfpHLkYzb4jgdtUFQSp0wUYD2Iw2X"

#This process uses the above credentials to secure a 'bearer token' 
#A unique token is gathered every time the program is run because these tokens are subject to change
bearCred = cKey + ":" + cSec
encCred = Base64.strict_encode64(bearCred)

res = RestClient::Resource.new "https://api.twitter.com/oauth2/token/"
$response = ''

    options = {}
    options['Authorization'] = "Basic #{encCred}"
    options['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8'

    RestClient.post("https://api.twitter.com/oauth2/token/", 'grant_type=client_credentials', options) do |response, request, result|
        
        #Debugging data
        $response << "#{CGI::escapeHTML(response.inspect)}<br /><br />"
        $response << "#{CGI::escapeHTML(request.inspect)}<br /><br />"
        $response << "#{CGI::escapeHTML(result.inspect)}<br />"

        $bearTok =  (JSON.parse(response))["access_token"]
    end

#This is the old way of tapping the Twitter API

=begin
$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "ddn7p7gNZGvO5193GGilWTeW4"
  config.consumer_secret     = "dnRZW4IChVL4bNgBSUE0C2ees8sN7PWvfUg3iQcVl8Iun8g7WG"
  config.access_token        = "941850966-k9gNxw8TmeXjunOSIpnqlWb9fiTaIhY1KfB5lvzG"
  config.access_token_secret = "VLVo41nSMLMCuVU3qfpHLkYzb4jgdtUFQSp0wUYD2Iw2X"
end
=end

