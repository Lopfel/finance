require 'rails_helper'

RSpec.describe PortfoliosController, type: :controller do
  let(:user) { create(:user) }
  let(:portfolio) do
    p = build(:portfolio, user: user)
    p.portfolio_allocations.build(stock: create(:stock), target_percentage: 100.0)
    p.save!
    p
  end

  let(:other_portfolio) do
    p = build(:portfolio, user: other_user)
    p.portfolio_allocations.build(stock: create(:stock), target_percentage: 100.0)
    p.save!
    p
  end


  before do
    session[:user_id] = user.id
  end

  describe 'GET #show' do
    let(:dashboard_data_double) do
      instance_double(
        Portfolios::DashboardData,
        call: {
          holdings: [],
          allocations: [],
          holdings_data: {},
          total_value: 1500.0,
          positions_count: 3,
          stocks: [],
          selected_stock: nil,
          chart_range: '1M',
          rebalance_actions: [],
          allocation_data: {},
          target_allocation_total: 100,
          rebalance_count: 0
        }
      )
    end

    it 'calls DashboardData service and assigns dashboard variables' do
      expect(Portfolios::DashboardData).to receive(:new).with(
        portfolio,
        ticker: nil,
        range: nil
      ).and_return(dashboard_data_double)

      get :show, params: { id: portfolio.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:total_value)).to eq(1500.0)
      expect(assigns(:positions_count)).to eq(3)
    end
  end

  describe 'GET #historical_prices' do
    let(:historical_prices_double) do
      instance_double(Portfolios::HistoricalPrices, call: { "AAPL" => [ 100, 105 ] })
    end

    it 'returns JSON with historical prices' do
      expect(Portfolios::HistoricalPrices).to receive(:new).with(
        portfolio,
        ticker: 'AAPL',
        range: '1M'
      ).and_return(historical_prices_double)

      get :historical_prices, params: { id: portfolio.id, ticker: 'AAPL', range: '1M' }, format: :json

      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('application/json')

      json_response = JSON.parse(response.body)
      expect(json_response).to eq({ "AAPL" => [ 100, 105 ] })
    end

    it 'returns not_found status when ActiveRecord::RecordNotFound is raised' do
      allow(Portfolios::HistoricalPrices).to receive(:new).and_raise(ActiveRecord::RecordNotFound)

      get :historical_prices, params: { id: portfolio.id }, format: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #rebalance' do
    let(:analyzer_double) do
      instance_double(
        Portfolios::AllocationAnalyzer,
        call: { rebalance_actions: [ { action: 'buy' } ] }
      )
    end

    context 'when format is HTML' do
      it 'runs the analyzer and redirects with a notice' do
        expect(Portfolios::AllocationAnalyzer).to receive(:new).with(portfolio).and_return(analyzer_double)

        post :rebalance, params: { id: portfolio.id }

        expect(response).to redirect_to(portfolio_path(portfolio))
        expect(flash[:notice]).to eq("Portfolio rebalancing analysis completed.")
      end
    end

    context 'when format is JSON' do
      it 'returns rebalance actions as JSON' do
        expect(Portfolios::AllocationAnalyzer).to receive(:new).with(portfolio).and_return(analyzer_double)

        post :rebalance, params: { id: portfolio.id }, format: :json

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('application/json')

        json_response = JSON.parse(response.body)
        expect(json_response).to eq([ { "action" => "buy" } ])
      end
    end
  end

  describe 'before_action :set_portfolio and authentication' do
    context 'when user is not logged in' do
      before { session[:user_id] = nil }

      it 'redirects or halts authentication' do
        get :show, params: { id: portfolio.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when portfolio does not belong to the user' do
      let(:other_user) { create(:user) }
      let(:other_portfolio) do
        p = build(:portfolio, user: other_user)
        p.portfolio_allocations.build(stock: create(:stock), target_percentage: 100.0)
        p.save!
        p
      end
      it 'redirects to session path with an alert because set_portfolio returns nil' do
        get :show, params: { id: other_portfolio.id }

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("You are not authorized to access this portfolio.")
      end
    end
  end
end
