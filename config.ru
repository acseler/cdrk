require "./lib/codebreaker_rack_app/rack_system"
use Rack::Static, :urls => ["/css"], :root => "lib/views"
use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           expire_after: 25200,
                           secret: 'dont_even_try'

run CodebreakerRackApp::RackSystem