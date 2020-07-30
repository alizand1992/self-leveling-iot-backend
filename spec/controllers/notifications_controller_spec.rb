require 'rails_helper'

RSpec.describe NotificationsController do
  describe '#create' do
    context 'user is not logged in' do
      it 'raises an exception' do
        expect { post :create }.to raise_error(IOError)
      end
    end
  end
end
