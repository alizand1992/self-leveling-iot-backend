# frozen_string_literal: true

RSpec.describe ApplicationController do
  describe 'POST user_data' do
    let(:user) { create(:user) }

    context 'User is not logged in' do
      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:authenticate_user!)
          .and_return(nil)
      end

      it 'returns unauthorized status' do
        post :user_data
        expect(response.status).to eq(401)
      end
    end

    context 'User is logged in' do
      before do
        sign_in user
      end

      it 'returns status ok' do
        post :user_data
        expect(response.status).to eq(200)
      end
    end
  end
end
