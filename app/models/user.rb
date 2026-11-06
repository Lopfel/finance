class User < ApplicationRecord
  has_many :portfolios, dependent: :destroy

  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
