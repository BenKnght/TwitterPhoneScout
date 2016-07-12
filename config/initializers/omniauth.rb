Rails.application.config.middleware.use OmniAuth::Builder do 
	provider :twitter, $cKey, $cSec
end