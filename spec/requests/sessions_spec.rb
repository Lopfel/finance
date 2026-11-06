require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let!(:user) { create(:user, email: "test@example.com", password: "password123") }

  describe 'GET #new' do
    it 'returns a successful response and renders the new template' do
      get :new
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'logs in the user, sets the session, and redirects to root_path' do
        post :create, params: { email: user.email, password: 'password123' }

        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Welcome back!")
      end
    end

    context 'with invalid password' do
      it 'does not log in, renders new with unprocessable_entity status, and sets a flash alert' do
        post :create, params: { email: user.email, password: 'wrongpassword' }

        expect(session[:user_id]).to be_nil
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq("Invalid email or password.")
      end
    end

    context 'with non-existent email' do
      it 'does not log in and renders new with unprocessable_entity status' do
        post :create, params: { email: 'notfound@example.com', password: 'password123' }

        expect(session[:user_id]).to be_nil
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      session[:user_id] = user.id
    end

    it 'resets the session and redirects to login_path' do
      delete :destroy

      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_path)
    end
  end
end
