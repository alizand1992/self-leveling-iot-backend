# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Device, type: :model do
  describe '.sync_with_aws' do
    subject { described_class.sync_with_aws }

    context 'fails to make a connection' do
      class ErrorRes
        attr_reader :code

        def initialize
          @code = '403'
        end
      end

      let(:error_res) { ErrorRes.new }

      before do
        Net::HTTP.any_instance.stub(:request).and_return(error_res)
      end

      it 'raises an exception' do
        expect { subject }.to raise_error(Exception)
      end

      it 'has the right message' do
        expect { subject }.to raise_error(Device::SYNC_ERROR)
      end
    end

    context 'successfully makes a connection' do
      let(:expected_ids) do
        %w[
          e750ec0f-00a8-44d5-8881-c4edd52fb6ab
          e750ec0f-00a8-44d5-8881-c4edd52fb6ac
        ]
      end
      class SuccessRes
        attr_reader :code, :body

        def initialize
          @code = '200'
          @body = "[{\"healthy\":{\"BOOL\":true},\"password\":{\"S\":\"03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4\"},\"id\":{\"S\":\"e750ec0f-00a8-44d5-8881-c4edd52fb6ab\"},\"level\":{\"BOOL\":true},\"battery\":{\"N\":\"80.5\"}}, {\"healthy\":{\"BOOL\":true},\"password\":{\"S\":\"03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4\"},\"id\":{\"S\":\"e750ec0f-00a8-44d5-8881-c4edd52fb6ac\"},\"level\":{\"BOOL\":true},\"battery\":{\"N\":\"80.5\"}}]"
        end
      end

      let(:success_res) { SuccessRes.new }

      before do
        Net::HTTP.any_instance.stub(:request).and_return(success_res)
      end

      context 'no data in the database yet' do
        before do
          subject
        end

        it 'has two entries in DB' do
          expect(described_class.count).to eq 2
        end

        it 'has the expected ids' do
          described_class.all.pluck(:aws_device_id).each do |id|
            expect(expected_ids).to include id
          end
        end
      end

      context 'there is already an id in the DB' do
        let(:new_id) { 'e750ec0f-00a8-44d5-8881-c4edd52fb6ac' }
        let(:old_id) { 'e750ec0f-00a8-44d5-8881-c4edd52fb6ab' }

        before do
          create(:unregistered_device, aws_device_id: old_id)
        end

        it 'only adds one' do
          expect(Device.count).to eq 1
          subject
          expect(Device.count).to eq 2
        end

        it 'adds the right one' do
          expect(Device.where(aws_device_id: new_id).size).to eq 0
          subject
          expect(Device.where(aws_device_id: new_id).size).to eq 1
        end

        it 'does not change the old one' do
          old_device = Device.where(aws_device_id: old_id).first
          subject
          expect(Device.where(aws_device_id: old_id).first).to eq old_device
        end
      end
    end
  end

  describe '.user_devices' do
    subject { Device.user_devices(user_id) }

    let(:user) { create(:user) }
    let(:user_id) { nil }
    let!(:device_1) { create(:registered_device, user: user) }
    let!(:device_2) { create(:registered_device, user: user) }
    let!(:device_3) { create(:unregistered_device) }

    it 'returns an array' do
      expect(subject).to be_kind_of(Array)
    end

    context 'user_id is null (unregistered devices)' do
      it 'returns the right number of devices' do
        expect(subject.size).to eq 1
      end

      it 'returns the right device' do
        expect(subject.first[:aws_device_id]).to eq device_3.aws_device_id
      end
    end

    context 'user_id is not null (registered devices)' do
      context 'devices belong to this user' do
        let(:user_id) { user.id }

        it 'returns the right number of devices' do
          expect(subject.size).to eq 2
        end

        it 'returns the right devices' do
          aws_device_ids = subject.map { |device| device[:aws_device_id] }

          expect(aws_device_ids).to include device_1.aws_device_id
          expect(aws_device_ids).to include device_2.aws_device_id
        end
      end

      context 'devices do not belong to this user' do
        let(:user_id) { user.id + 1 }

        it 'returns the right number of devices' do
          expect(subject.size).to eq 0
        end
      end
    end
  end
end
