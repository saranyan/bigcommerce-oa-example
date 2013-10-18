helpers do
  def csrf_token
    Rack::Csrf.csrf_token(env)
  end

  def csrf_tag
    Rack::Csrf.csrf_tag(env)
  end

  def redirect_to_home
	  if(session[:user_id]).nil?
	    redirect "/sign_in"
	  end
  end

  
  def bc_get_resource(store_hash,resource,client_id,token,params={})
    JSON.parse(RestClient.get("https://api.bigcommerceapp.com/stores/#{store_hash}/v2/#{resource}", :params=> params, :'x-auth-client' =>"#{client_id}", :'x-auth-token' => "#{token}", :accept=>:json))
  end

  def bc_delete_resource_id(store_hash,resource,resource_id,client_id,token)
    JSON.parse(RestClient.delete("https://api.bigcommerceapp.com/stores/#{store_hash}/v2/#{resource}/#{resource_id}", :'x-auth-client' =>"#{client_id}", :'x-auth-token' => "#{token}", :accept=>:json))
  end

  def bc_get_resource_id(store_hash,resource,resource_id,client_id,token,params={})
    JSON.parse(RestClient.get("https://api.bigcommerceapp.com/stores/#{store_hash}/v2/#{resource}/#{resource_id}", :params=> params, :'x-auth-client' =>"#{client_id}", :'x-auth-token' => "#{token}", :accept=>:json))
  end

  def bc_create_resource(store_hash,resource,client_id,token,data)
    JSON.parse(RestClient.get("https://api.bigcommerceapp.com/stores/#{store_hash}/v2/#{resource}", data.to_json, :'x-auth-client' =>"#{client_id}", :'x-auth-token' => "#{token}", :accept=>:json, :content_type=> :json))
  end

  def bc_update_resource(store_hash,resource,resource_id,client_id,token,data)
    JSON.parse(RestClient.put("https://api.bigcommerceapp.com/stores/#{store_hash}/v2/#{resource}/#{resource_id}", data.to_json, :'x-auth-client' =>"#{client_id}", :'x-auth-token' => "#{token}", :accept=>:json, :content_type=> :json))
  end

end