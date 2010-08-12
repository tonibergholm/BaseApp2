require 'digest/sha1'

class User < ActiveRecord::Base
  # include Authorization::AasmRoles

  # Include default devise modules. Others available are:
  devise :database_authenticatable, :http_authenticatable, :recoverable, :registarable, :rememberable

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => /\w+/

  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email,    :if => lambda { |e| !e.openid_login? && !e.twitter_login? }
  validates_uniqueness_of   :email,    :if => lambda { |e| !e.openid_login? && !e.twitter_login? }
  validates_length_of       :email,    :within => 6..100, :allow_nil => true, :if => lambda { |e| !e.email.blank? }
  validates_format_of       :email,    :with => Devise::EMAIL_REGEX, :allow_blank => true

  with_options :if => :password_required? do |v|
    v.validates_presence_of     :password
    v.validates_confirmation_of :password
    v.validates_length_of       :password, :within => 6..20, :allow_blank => true
  end
  
  # Relations
  has_and_belongs_to_many :roles
  has_one :profile
  
  # Hooks
  after_create :create_profile
  
  attr_accessible :login, :email, :name, :password, :password_confirmation, :identity_url
  
  # has_role? simply needs to return true or false whether a user has a role or not.  
  # It may be a good idea to have "admin" roles return true always
  def has_role?(role)
    list ||= self.roles.collect(&:name)
    list.include?(role.to_s) || list.include?('admin')
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def openid_login?
    !identity_url.blank? #|| (AppConfig.enable_facebook_auth && !facebook_id.blank?)
  end

  def twitter_login?
    !twitter_token.blank? && !twitter_secret.blank?
  end
  
  def not_using_openid?
    !openid_login?
  end
  
  def normalize_identity_url
    self.identity_url = OpenIdAuthentication.normalize_url(identity_url) if openid_login?
  rescue
    errors.add_to_base("Invalid OpenID URL")
  end
  
  def self.find_by_login_or_email(login_or_email)
    find(:first, :conditions => ['login = ? OR email = ?', login_or_email, login_or_email])
  rescue
    nil
  end
    
protected


  def password_required?
    return false if openid_login?
    return false if twitter_login?
    (encrypted_password.blank? || !password.blank?)
  end

  
  def create_profile
    # Give the user a profile
    self.profile = Profile.create    
  end

end
