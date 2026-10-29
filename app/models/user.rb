class User < ApplicationRecord
  validate :name, present: true
end
