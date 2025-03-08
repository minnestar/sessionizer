class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "email",
      "created_at",
      "remember_created_at",
      "reset_password_sent_at",
      "reset_password_token",
      "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
