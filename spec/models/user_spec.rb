require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user, name: 'Juan', email: 'juan@example.com', password: 'password123') }

  it 'Is valid with a name and email' do
    user = User.new(name: 'Juan', email: 'juan@example.com', password: 'password123')
    expect(user).to be_valid
  end

  it 'Is not valid without a name' do
    user = User.new(email: 'juan@example.com', password: 'password123')
    expect(user).not_to be_valid
  end
end
