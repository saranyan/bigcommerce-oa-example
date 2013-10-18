source 'http://rubygems.org'

gem "sinatra"
gem "data_mapper"


#gem "dm-sqlite-adapter"

group :production do
    gem "pg"
    gem "dm-postgres-adapter"
end

group :development do
    gem "sqlite3"
    gem "dm-sqlite-adapter"
end


gem 'sinatra-flash' # or `gem 'rack-flash'`
gem 'sinatra-redirect-with-flash'
gem  'rack_csrf'
gem 'rack-protection'
gem 'rest-client'
gem 'oauth'

gem 'omniauth-bigcommerce', :git => 'git://github.com/bigcommerce/omniauth-bigcommerce.git'

gem 'geocoder'