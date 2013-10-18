require 'rubygems'
require 'sinatra'
require 'data_mapper'

require 'sinatra/flash' # or `require 'rack-flash'`
require 'sinatra/redirect_with_flash'
require "rack/csrf"
require "rack/protection"
require_relative 'helpers/app_helper'
require 'date'
require 'time'

require 'omniauth'
require 'omniauth-bigcommerce'

require 'oauth'
require 'rest_client'
require 'json'
require 'geocoder'

enable :sessions


configure do

  set :session_secret, (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
  use Rack::Csrf, :skip_if => lambda { |request|
    #p request.env
    request.env.key?('HTTP_X_BC438943_GEOIP')
  }
  disable :protection
  
end

Geocoder.configure(
   :lookup => :bing,
   :api_key => ENV['bing_key']
)

$CLIENT_ID = ENV['client_id']
$CLIENT_SECRET = ENV['client_secret']


use OmniAuth::Builder do
  provider :bigcommerce, $CLIENT_ID, $CLIENT_SECRET, scope: "v2_api_all",
  :client_options => {:site => "https://login.bigcommerceapp.com"}
end

register Sinatra::Flash
helpers Sinatra::RedirectWithFlash
set :public_folder, File.dirname(__FILE__) + '/static'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")
require_relative 'models/user'

DataMapper.finalize.auto_upgrade!

get '/' do
  if session[:user_id]
    user = User.get(session[:user_id])
    # p user
    orders = bc_get_resource(user.store_hash,"orders",$CLIENT_ID,user.token,{})
    #p orders
    @p = []
    orders.each do |o|
      data = Geocoder.search( o["billing_address"]["zip"] ).first
      if !data.nil?
        latlng = data.data["point"]["coordinates"]
        temp = {"lat" => latlng[0], "lng" => latlng[1]}
        @p << temp.merge!({"id" => o["id"], "name" => "#{o["billing_address"]["first_name"]} #{o["billing_address"]["last_name"]}"})
      end
    end
    # p @p
    erb :index
    #return "hello #{user.email} #{orders}"
    #return "#{p}"
  else
    return "Oh, hello stranger"
  end
  
end

get '/test' do
  user = User.get(1)
  #orders = bc_get_resource(user.store_hash,"orders",$CLIENT_ID,user.token,{})
    @p = []
    orders = ["78759","45435","96002"]
    orders.each do |o|
      latlng = Geocoder.search( o ).first.data["point"]["coordinates"]
      temp = {"lat" => latlng[0], "lng" => latlng[1]}
      @p << temp.merge({"id" => o, "name" => "foo"})
    end
  erb :index

end

get '/auth/:name/callback' do

    auth = request.env['omniauth.auth']
    if auth && auth[:extra][:raw_info][:context]

      store_hash = auth[:extra][:raw_info][:context].split('/')[1]
      user = User.first(:store_hash => store_hash,:email => auth[:info][:email],)
      unless user
        user = User.new({ 
                          :store_hash => store_hash,
                          :email => auth[:info][:email]
                        })
      end
      user.token = auth[:credentials][:token].token
      user.save!
      session[:user_id] = user.id
      return redirect '/'
    end
    return '<h1>Invalid credentials! Got: '+JSON.pretty_generate(auth[:extra])+'</h1>'
end

get '/load' do
  signed_payload = params[:signed_payload]

  unless verify(signed_payload, $CLIENT_SECRET)
    return '<h1>Invalid signature on payload!</h1>'
  end

  parts = signed_payload.split('.')
  payload = JSON.parse(Base64.decode64(parts[0]), {:symbolize_names => true})
  p payload
  p User.all
  user = User.first(:store_hash => payload[:store_hash], :email => payload[:user][:email])
  unless user
    #create a user (bug in canvas, unable to install app - user account did not get created during initial oauth flow)
    #user = User.new(:store_hash => "store/"+payload[:storehash], :token => )

      return '<h1>Invalid user!</h1>'
    # user = User.new(:store_hash => payload[:storehash],:token => token.token)
    # u = User.authenticate(user)
    # if u
    #   session[:user_id] = u.id
    #   redirect "/"
    # else
      
    #   if user.save
    #     session[:user_id] = user.id
    #     redirect '/'
    #   else
    #     erb :splash
    #   end
    # end
  end
  session[:user_id] = user.id
  redirect '/'
end

def verify(signed_payload, client_secret)
  message_parts = signed_payload.split('.')

  encoded_json_payload = message_parts[0]
  encoded_hmac_signature = message_parts[1]

  payload_object = Base64.decode64(encoded_json_payload)
  provided_signature = Base64.decode64(encoded_hmac_signature)

  expected_signature = OpenSSL::HMAC::hexdigest('sha256', client_secret, payload_object)

  return false unless secure_compare(expected_signature, provided_signature)

  payload_object
end

def secure_compare(a, b)
  return false if a.blank? || b.blank? || a.bytesize != b.bytesize
  l = a.unpack "C#{a.bytesize}"
  res = 0
  b.each_byte { |byte| res |= byte ^ l.shift }
  res == 0
end
