# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevicesController, type: :controller do
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
end
