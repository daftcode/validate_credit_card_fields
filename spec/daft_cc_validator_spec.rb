require 'spec_helper'

describe DaftCcValidator do

  context 'Implemented model' do
    let(:dummy) { User.new }

    context 'credit card number' do

      it 'must be present' do
        dummy.credit_card_number = nil
        should_have_error :credit_card_number, 'can\'t be empty'
      end
    end

    def should_have_error field, message
      dummy.valid?
      expect(dummy.errors.messages[field]).to include message
    end
  end

end
