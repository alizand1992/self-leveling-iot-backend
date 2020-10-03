# frozen_string_literal: true

RSpec.describe TriggersController do
  describe 'POST create' do
    context 'user logged in' do
      let(:user) { create(:user) }
      let(:params) do
        {
          aws_column: 'battery',
          relationship: 'less than',
          trigger_type: 'float',
          value: '20.0',
          notification_id: notification.id
        }
      end

      before do
        sign_in user
      end

      context 'notification belongs to this user' do
        let(:notification) { create(:notification, user: user) }
        let(:success) { JSON.parse(response.body)['success'] }


        it 'creates returns a :ok status' do
          post :create, params: params

          expect(response.status).to eq(200)
        end

        it 'response with the success' do
          post :create, params: params

          expect(success).to be_present
        end

        it 'has an id (is saved)' do
          post :create, params: params

          expect(success).to eq('ok')
        end

        it 'creates the trigger' do
          post :create, params: params

          expect(Trigger.where(notification_id: notification.id).size).to eq(1)
        end
      end

      context 'notification does not belong to this user' do
        let(:another_user) { create(:user) }
        let(:notification) { create(:notification, user: another_user) }
        let(:error) { JSON.parse(response.body)['error'] }


        it 'creates returns a :unathorized status' do
          post :create, params: params

          expect(response.status).to eq(401)
        end

        it 'response with the success' do
          post :create, params: params

          expect(error).to eq(Trigger::DOES_NOT_OWN_NOTIFICATION_MSG)
        end
      end
    end
  end
end
