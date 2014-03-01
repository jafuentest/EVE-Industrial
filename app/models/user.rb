class User < ActiveRecord::Base
  require 'digest/sha1'
  
  attr_accessible :is_admin, :login, :password
  
  before_save :encrypt_password
  
  validates_confirmation_of :password
  validates_presence_of :password
  validates_presence_of :login
  validates_uniqueness_of :login
  
  def self.authenticate(input)
    user = find_by_login(input[:login])
    if user && user.password == Digest::SHA1.hexdigest(input[:password])
      user
    else
      nil
    end
  end
  
  def encrypt_password
    if password.present?
      self.password = Digest::SHA1.hexdigest password
    end
  end
end
