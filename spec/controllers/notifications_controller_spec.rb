# frozen_string_literal: true

RSpec.describe NotificationsController do
  describe 'POST create' do
    context 'user logged in' do
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

  describe 'GET index' do
    let(:user) { create(:user) }
    let!(:notification) { create(:notification, user_id: user.id) }

    context 'user logged in' do
      let(:res) { JSON.parse(response.body)['notifications'].to_json }

      before do
        sign_in user
      end

      it 'gets the notification from the database' do
        get :index

        expect(res).to eq([notification].to_json)
      end
    end

    context 'user is not logged in' do
      before do
        allow_any_instance_of(NotificationsController)
          .to receive(:authenticate_user!)
          .and_return(nil)
      end

      it 'has unauthorized status' do
        get :index

        expect(response.status).to eq(401)
      end
    end
  end
end
