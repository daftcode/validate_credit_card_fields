require 'spec_helper'

def should_have_error field, message
  dummy.valid?
  expect(dummy.errors.messages[field]).to include message
end

def has_valid *fields
  dummy.valid?
  fields.to_a.each do |field|
    expect(dummy.errors.messages[field]).not_to be
  end
end


describe ValidateCreditCardFields do

  context 'Implemented model\'s credit card' do
    let(:dummy) { User.new }

    context 'owner' do

      it 'must be present' do
        dummy.credit_card_owner = nil
        should_have_error :credit_card_owner, 'can\'t be blank'
      end

      it 'raises an error if it\'s not a string' do
        dummy.credit_card_owner = 1
        expect{dummy.valid?}.to raise_error{CCTypeError}
      end

      it 'not raising error if nil' do
        dummy.credit_card_owner = nil
        expect{dummy.valid?}.not_to raise_error{CCTypeError}
      end
    end

    context 'number' do

      it 'must be present' do
        dummy.credit_card_number = nil
        should_have_error :credit_card_number, 'can\'t be blank'
      end

      it 'must have a valid provider' do
        dummy.credit_card_number = '0000'
        should_have_error :credit_card_number, 'is invalid'
      end

      it 'must have a supported provider' do
        dummy.credit_card_number = '36255264496934' # => diner's club
        dummy.valid?
        expect(dummy.errors[:credit_card_number].length).to eq(1)
      end

      it 'raises an error if it\'s not a string' do
        dummy.credit_card_number = 1
        expect{dummy.valid?}.to raise_error{CCTypeError}
      end

      it 'not raising error if nil' do
        dummy.credit_card_number = nil
        expect{dummy.valid?}.not_to raise_error{CCTypeError}
      end

      describe 'Luhn algorithm' do

        it 'is invalid with bad checksum' do
          dummy.credit_card_number = '4111111111111110' # => visa
          should_have_error :credit_card_number, 'is invalid'
        end

        it 'has no errors with valid card number' do
          valid_card_numbers = %w(4111111111111111 378282246310005 4012888888881881 371449635398431)
          valid_card_numbers.each do |ccn|
            dummy.credit_card_number = ccn
            has_valid :credit_card_number
          end
        end

      end

    end

    context 'cvv' do

      it 'must be present' do
        dummy.credit_card_cvv = nil
        should_have_error :credit_card_cvv, 'can\'t be blank'
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

      it 'raises an error if it\'s not a string' do
        dummy.credit_card_cvv = 1
        expect{dummy.valid?}.to raise_error{CCTypeError}
      end

      it 'not raising error if nil' do
        dummy.credit_card_cvv = nil
        expect{dummy.valid?}.not_to raise_error{CCTypeError}
      end
    end

    context 'month' do

      it 'must be present' do
        dummy.credit_card_month = nil
        should_have_error :credit_card_month, 'can\'t be blank'
      end

      it 'must be positive' do
        dummy.credit_card_month = '-1'
        should_have_error :credit_card_month, 'is invalid'
      end

      it 'must be an integer' do
        dummy.credit_card_month = '.5'
        should_have_error :credit_card_month, 'is invalid'
      end

      it 'accepts 2 digits' do
        dummy.credit_card_month = '11'
        has_valid :credit_card_month
      end

      it 'accepts 1 digit' do
        dummy.credit_card_month = '1'
        has_valid :credit_card_month
      end

      it 'accepts correct input' do
        dummy.credit_card_month = '12'
        has_valid :credit_card_month
      end

      it 'must be smaller than 12' do
        dummy.credit_card_month = '13'
        should_have_error :credit_card_month, 'is invalid'
      end

      it 'raises an error if it\'s not a string' do
        dummy.credit_card_month = 1
        expect{dummy.valid?}.to raise_error{CCTypeError}
      end

      it 'not raising error if nil' do
        dummy.credit_card_month = nil
        expect{dummy.valid?}.not_to raise_error{CCTypeError}
      end

    end

    context 'year' do

      it 'must be present' do
        dummy.credit_card_year = nil
        should_have_error :credit_card_year, 'can\'t be blank'
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

      it 'cannot be past' do
        dummy.credit_card_year = (Date.today.year-1).to_s[2..-1]
        should_have_error :credit_card_year, 'is invalid'
      end

      it 'accepts without leading zeros' do
        dummy.credit_card_month = "1"
        dummy.credit_card_year = (Date.today.year+1).to_s[2..-1]
        has_valid :credit_card_month, :credit_card_year
      end

      it 'accepts correct input' do
        dummy.credit_card_year = (Date.today.year+1).to_s[2..-1]
        has_valid :credit_card_year
      end

      it 'raises an error if it\'s not a string' do
        dummy.credit_card_year = 1
        expect{dummy.valid?}.to raise_error{CCTypeError}
      end

      it 'not raising error if nil' do
        dummy.credit_card_year = nil
        expect{dummy.valid?}.not_to raise_error{CCTypeError}
      end

    end

    context 'date' do

      it 'sets past year as invalid' do
        dummy.credit_card_month = '01'
        dummy.credit_card_year = '10'
        should_have_error :credit_card_year, 'is invalid'
      end

      it 'sets past month as invalid' do
        dummy.credit_card_month = '01'
        dummy.credit_card_year = Date.today.year.to_s[2..-1]
        should_have_error :credit_card_month, 'is invalid'
      end

      it 'accepts future date' do
        dummy.credit_card_month = '01'
        dummy.credit_card_year = (Date.today.year+1).to_s[2..-1]
        has_valid :credit_card_month, :credit_card_year
      end

      it 'accepts current date' do
        dummy.credit_card_month = "%02d" % Date.today.month
        dummy.credit_card_year = (Date.today.year).to_s[2..-1]
        has_valid :credit_card_month, :credit_card_year
      end

    end
  end

  describe 'validation options' do
    let(:default_fields) { [:cc_number, :cc_cvv, :cc_month, :cc_year, :cc_owner] }
    let(:default_options) { { providers: [:amex, :visa] } }
    let(:fields) { default_fields }
    let(:options) { default_options }

    let(:klass) {
      _fields = fields
      _opt = options
      Class.new do
        include ActiveModel::Validations
        attr_accessor *_fields
        validate_credit_card_fields _opt
      end
    }

    let(:dummy) { klass.new }

    context 'without settings' do
      it 'uses default field names' do
        expect{dummy.valid?}.not_to raise_error
      end
    end

    context 'with custom field' do
      let(:owner_field) { :custom_owner_field }
      let(:fields) { default_fields + [owner_field] }

      before {dummy.send("#{owner_field}=", 'John Test')}

      context 'passed as symbol' do
        let(:options) { default_options.merge({owner: owner_field}) }
        it 'uses custom field name' do
          has_valid owner_field
        end
      end

      context 'passed in hash' do
        let(:options) { default_options.merge({owner: {field: owner_field}}) }
        it 'uses custom field name' do
          has_valid owner_field
        end
      end
    end

    context 'with custom error message' do
      let(:error_msg) { 'custom error message' }
      let(:options) { default_options.merge({owner: {blank: error_msg}}) }
      it 'uses custom error message' do
        dummy.cc_owner = nil
        should_have_error :cc_owner, error_msg
      end
    end


  end

end
