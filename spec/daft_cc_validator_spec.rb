require 'spec_helper'

def should_have_error field, message
  dummy.valid?
  expect(dummy.errors.messages[field]).to include message
end

describe DaftCcValidator do

  context 'Implemented model\'s credit card' do
    let(:dummy) { User.new }

    context 'number' do

      it 'must be present' do
        dummy.credit_card_number = nil
        should_have_error :credit_card_number, 'can\'t be empty'
      end

      it 'must have a valid provider' do
        dummy.credit_card_number = '0000'
        should_have_error :credit_card_number, 'is invalid'
      end

      it 'must have a supported provider' do
        dummy.credit_card_number = '36255264496934' # => diner's club
        should_have_error :credit_card_number, 'provider is not supported'
      end
    end

    context 'cvv' do

      it 'must be present' do
        dummy.credit_card_cvv = nil
        should_have_error :credit_card_cvv, 'can\'t be empty'
      end

      it 'must be 4 digits long for an amex card' do
        dummy.credit_card_cvv = '123'
        dummy.credit_card_number = '377012652618992' # => amex
        should_have_error :credit_card_cvv, 'is invalid'
      end

      it 'must be 3 digits long for any other card' do
        dummy.credit_card_cvv = '1234'
        dummy.credit_card_number = '123'
        should_have_error :credit_card_cvv, 'is invalid'
      end
    end

    context 'month' do

      it 'must be present' do
        dummy.credit_card_month = nil
        should_have_error :credit_card_month, 'can\'t be empty'
      end

      it 'must be positive' do
        dummy.credit_card_month = '-1'
        should_have_error :credit_card_month, 'is invalid'
      end

      it 'must be an integer' do
        dummy.credit_card_month = '.5'
        should_have_error :credit_card_month, 'is invalid'
      end

      it 'must have 2 digits' do
        dummy.credit_card_month = '9'
        should_have_error :credit_card_month, 'is invalid'
      end

      it 'must be smaller than 12' do
        dummy.credit_card_month = '13'
        should_have_error :credit_card_month, 'is invalid'
      end
    end

    context 'year' do

      it 'must be present' do
        dummy.credit_card_year = nil
        should_have_error :credit_card_year, 'can\'t be empty'
      end

      it 'must be positive' do
        dummy.credit_card_year = '-1'
        should_have_error :credit_card_year, 'is invalid'
      end

      it 'must be an integer' do
        dummy.credit_card_year = '.5'
        should_have_error :credit_card_year, 'is invalid'
      end

      it 'must have 2 digits' do
        dummy.credit_card_year = '9'
        should_have_error :credit_card_year, 'is invalid'
      end

    end

    context 'date' do

      it 'year must be in the future' do
        dummy.credit_card_month = '01'
        dummy.credit_card_year = '10'
        should_have_error :credit_card_year, 'date is past'
      end
      
      it 'month must be in the future' do
        dummy.credit_card_month = '01'
        dummy.credit_card_year = Date.today.year.to_s[2..-1]
        should_have_error :credit_card_month, 'date is past'
      end
    end
  end

end
