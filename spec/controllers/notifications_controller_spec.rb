# frozen_string_literal: true

RSpec.describe NotificationsController do
  describe 'POST Create' do
    describe 'user logged in' do
      let(:user) { create(:user) }
      let(:params) do
        {
          name: 'Battery Low',
          description: 'Notify the user when the battery gets below 20%',
        }
      end
      let(:notification) { JSON.parse(response.body)['notification'] }

      before do
        sign_in user
      end

      it 'creates returns a :ok status' do
        post :create, params: params
        expect(response.status).to eq(200)
      end

      it 'response with the notification' do
        post :create, params: params

        expect(notification).to be_present
      end

      it 'has an id (is saved)' do
        post :create, params: params

        expect(notification['id']).to be_kind_of(Integer)
      end

      it 'has the user id of the current user' do
        post :create, params: params

        expect(notification['user_id']).to eq(user.id)
      end

      it 'has the name saved correctly' do
        post :create, params: params

        expect(notification['name']).to eq(params[:name])
      end

      it 'has the description saved correctly' do
        post :create, params: params

        expect(notification['description']).to eq(params[:description])
      end
    end
  end
end
