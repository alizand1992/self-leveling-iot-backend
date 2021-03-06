# frozen_string_literal: true

RSpec.describe TriggersController do
  describe 'GET index' do
    context 'user logged in' do
      let(:user) { create(:user) }
      let(:params) {{ notification_id: notification.id }}

      before do
        sign_in user
      end

      context 'notification belongs to this user' do
        let(:notification) { create(:notification, user: user) }
        let(:triggers) { JSON.parse(response.body)['triggers'] }

        context 'no triggers are saved' do
          it 'returns empty triggers' do
            get :index, params: params

            expect(triggers).to eq([])
          end
        end

        context 'triggers dont belong to notification' do
          let(:another_notification) { create(:notification, user: user) }
          let!(:trigger) { create(:trigger, notification: another_notification) }

          it 'returns empty triggers' do
            get :index, params: params

            expect(triggers).to eq([])
          end
        end

        context 'triggers belong to notification' do
          let!(:trigger) { create(:trigger, notification: notification) }

          it 'returns empty triggers' do
            get :index, params: params

            expect(triggers).not_to be_blank
          end
        end
      end

      context 'notification does NOT belong to this user' do
        let(:another_user) { create(:user) }
        let(:notification) { create(:notification, user: another_user) }
        let(:triggers) { JSON.parse(response.body)['triggers'] }
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

  describe 'PUT/PATCH update' do
    let(:user) { create(:user) }
    let(:params) do
      {
        id: trigger.id,
        aws_column: 'battery',
        relationship: 'less than',
        trigger_type: 'float',
        value: '22.0',
        notification_id: notification.id
      }
    end

    let(:notification) { create(:notification, user: user) }
    let(:trigger) { create(:trigger, notification: notification) }

    before do
      sign_in user
    end

    it 'responses with a 200' do
      put :update, params: params

      expect(response.status).to eq(200)
    end

    it 'updates the trigger' do
      put :update, params: params

      expect(Trigger.find(trigger.id).value).to eq('22.0')
    end
  end

  describe 'DELETE destroy' do
    let(:user) { create(:user) }
    let(:params) {{ id: trigger.id, notification_id: notification.id }}

    let(:notification) { create(:notification, user: user) }
    let(:trigger) { create(:trigger, notification: notification) }

    before do
      sign_in user
    end

    it 'responses with a 200' do
      delete :destroy, params: params

      expect(response.status).to eq(200)
    end

    it 'deletes the record from db' do
      delete :destroy, params: params

      expect{ Trigger.find(trigger.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET attributes' do
    let(:attributes) { JSON.parse(response.body)['attributes'] }
    let(:expected) { Trigger::ATTRIBUTES.deep_stringify_keys }

    it 'returns the attribute constant from trigger model' do
      get :attributes

      expect(attributes).to eq(expected)
    end
  end
end
