require 'rails_helper'

RSpec.describe PortfolioAllocation, type: :model do
  describe 'asociaciones' do
    it { should belong_to(:portfolio) }
    it { should belong_to(:stock) }
  end
end
