class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  def self.admin
    @@admin ||= find_by_name("admin")
  end
  
end