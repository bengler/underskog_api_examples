Bundler.require

require 'sinatra/base'
require 'sinatra/reloader'

require ::File.expand_path('../app', __FILE__)

UNDERSKOG_API_KEY = '9vLOqXqW8v88IoTRcIfNG0zeiJ5j6O6xgR1jTt6D'
UNDERSKOG_SECRET = 'AWJ4z5H1fJZca3WtPLEXSTphkACPUNzv7hFlbbJT'

use Rack::Session::Cookie, key: 'session', secret: 'dd535f8acf264d33ac47f2fbce8afef2'

use OmniAuth::Builder do
  provider :underskog, UNDERSKOG_API_KEY, UNDERSKOG_SECRET, setup: true
  on_failure do |env|
    message_key = env['omniauth.error.type']
    new_path = "/oauth/failure?message=#{message_key}"
    [302, {'Location' => new_path, 'Content-Type'=> 'text/html'}, []]
  end
end

run Application