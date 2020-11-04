# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevicesController, type: :controller do
  describe 'GET#index' do
    let(:res) { JSON.parse(response.body) }

    context 'No devices at all' do
      before do
        get :index
      end

      it 'returns a 200 status' do
        expect(response.status).to eq 200
      end

      it 'renders devices as an empty array' do
        expect(res['devices']).to eq []
      end
    end

    context 'all devices already registered' do
      before do
        (0..5).to_a.each do |_i|
          create(:registered_device)
        end

        get :index
      end

      it 'returns a 200 status' do
        expect(response.status).to eq 200
      end

      it 'renders devices as an empty array' do
        expect(res['devices']).to eq []
      end
    end

    context 'some devices are registered and some aren\'t' do
      before do
        (0..5).to_a.each do |index|
          if index % 2 == 0
            create(:registered_device)
          else
            create(:unregistered_device)
          end
        end

        get :index
      end

      it 'returns a 200 status' do
        expect(response.status).to eq 200
      end

      it 'render the right number of devices' do
        expect(res['devices'].size).to eq 3
      end
    end
  end

  describe 'GET#sync' do
    let(:res) { JSON.parse(response.body) }

    context 'sync_with_aws succeeds' do
      before do
        allow(Device).to receive(:sync_with_aws).and_return(nil)
        get :sync
      end

      it 'returns status ok' do
        expect(response.status).to eq 200
      end

      it 'returns success ok' do
        expect(res['success']).to eq 'ok'
      end
    end

    context 'sync_with_aws throws an error' do
      before do
        allow(Device).to receive(:sync_with_aws).and_raise(StandardError.new(Device::SYNC_ERROR))
        get :sync
      end

      it 'returns status internal_server_error' do
        expect(response.status).to eq 500
      end

      it 'returns error message' do
        expect(res['error']).to eq Device::SYNC_ERROR
      end
    end
  end

  describe 'POST#register' do
    context 'user is signed in' do
      let(:res) { JSON.parse(response.body) }
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      describe 'missing required params' do
        before do
          post :register, params: params
        end

        context 'aws_device_id' do
          let(:params) { { device_name: 'Front porch table' } }

          it 'returns a bad request status' do
            expect(response.status).to eq 400
          end

          it 'returns the correct error message' do
            expect(res['error']).to start_with('param is missing or the value is empty')
          end
        end

        context 'device_name' do
          let(:params) { { aws_device_id: Random.uuid } }

          it 'returns a bad request status' do
            expect(response.status).to eq 400
          end

          it 'returns the correct error message' do
            expect(res['error']).to start_with('param is missing or the value is empty')
          end
        end
      end

      context 'there is a device' do
        let(:aws_device_id) { Random.uuid }

        context 'device is not registered to anyone' do
          let!(:device) { create(:unregistered_device, aws_device_id: aws_device_id) }

          before do
            post :register, params: params
          end

          context 'correct id is provided' do
            let(:params) { { aws_device_id: aws_device_id, device_name: 'Front Porch Table' } }

            it 'returns a 200 status' do
              expect(response.status).to eq 200
            end

            it 'returns success message' do
              expect(res['success']).to eq 'ok'
            end

            it 'stores the changes on the DB' do
              expect(Device.find(device.id).user_id).to eq user.id
            end
          end

          context 'incorrect id is supplied' do
            let(:params) { { aws_device_id: Random.uuid(), device_name: 'Front Porch Table' } }

            it 'returns a 200 status' do
              expect(response.status).to eq 400
            end

            it 'returns error message' do
              expect(res['error']).to eq Device::DEVICE_NOT_FOUND
            end

            it 'does not store the changes on the DB' do
              expect(Device.find(device.id).user_id).to eq nil
            end
          end
        end

        context 'device is registered to someone' do
          let!(:device) { create(:registered_device, aws_device_id: aws_device_id) }
          let(:params) { { aws_device_id: aws_device_id, device_name: 'Front Porch Table' } }

          before do
            post :register, params: params
          end

          it 'returns a 400 status' do
            expect(response.status).to eq 400
          end

          it 'returns an error message' do
            expect(res['error']).to eq Device::DEVICE_NOT_FOUND
          end
        end
      end
    end
  end

  describe 'PATCH#unregister' do
    let(:res) { JSON.parse(response.body) }

    context 'device belongs to user' do
      let(:user) { create(:user) }
      let!(:device) { create(:registered_device, user_id: user.id) }

      before do
        sign_in user
        patch :unregister, params: { aws_device_id: device.aws_device_id }
      end

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      it 'returns a success ok' do
        expect(res['success']).to eq 'ok'
      end

      it 'unregisters the device' do
        expect(Device.find(device.id).user_id).to eq nil
      end
    end

    context 'device does not belong to the user' do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }
      let!(:device) { create(:registered_device, user_id: user1.id) }

      before do
        sign_in user2
        patch :unregister, params: { aws_device_id: device.aws_device_id }
      end

      it 'returns status 200' do
        expect(response.status).to eq 400
      end

      it 'returns a success ok' do
        expect(res['error']).to eq Device::DEVICE_NOT_FOUND
      end

      it 'unregisters the device' do
        expect(Device.find(device.id).user_id).to eq user1.id
      end
    end
  end
end
