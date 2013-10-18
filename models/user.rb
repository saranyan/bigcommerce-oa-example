
class User
  include DataMapper::Resource
  #include DataMapper::Resource
  
  property :id,			        Serial
  property :email,	String, :required => true
  property :store_hash,		    String, :required => true
  property :token, 			String, :required => true
  #attr_accessor :username,:apikey,:storeurl
  validates_presence_of :store_hash, :token
  validates_uniqueness_of :store_hash
  
  def self.authenticate(user)
    u = User.first(:store_hash => user.store_hash, :email => user.email)
    return nil if u.nil?
    return u
    nil
  end

 end