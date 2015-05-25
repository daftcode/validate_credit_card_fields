class CCTypeError < StandardError;
end

require 'daft_cc_validator/version'
require 'monads/optional'
require 'date'

module ActiveModel
  module Validations

    class DaftCcValidator < Validator
      include Monads

      ERROR_TYPES = [:invalid, :blank, :not_supported]

      PROVIDERS = {
          visa: /^4[0-9]{12}(?:[0-9]{3})?$/,
          master_card: /^5[1-5][0-9]{14}$/,
          maestro: /(^6759[0-9]{2}([0-9]{10})$)|(^6759[0-9]{2}([0-9]{12})$)|(^6759[0-9]{2}([0-9]{13})$)/,
          diners_club: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
          amex: /^3[47][0-9]{13}$/,
          discover: /^6(?:011|5[0-9]{2})[0-9]{12}$/,
          jcb: /^(?:2131|1800|35\d{3})\d{11}$/
      }

      attr_accessor :options, :cc_number, :cc_cvv, :cc_month,
                    :cc_year, :cc_owner, :cc_providers, :cc_type, :custom_messages

      def initialize(options={})
        @options = options
        @custom_messages = {}
        @cc_number = init_option(:number, :cc_number)
        @cc_cvv = init_option(:cvv, :cc_cvv)
        @cc_month = init_option(:month, :cc_month)
        @cc_year = init_option(:year, :cc_year)
        @cc_owner = init_option(:owner, :cc_owner)
        @cc_providers = options[:providers]
      end

      def init_option(key, default)
        if options[key].is_a? Hash
          init_option_from_hash options[key], default
        else
          options[key] || default
        end
      end
      
      def init_option_from_hash(hash, default)
        field_name = hash[:field] || default
        custom_messages[field_name] = hash.select{ |k,_| ERROR_TYPES.include? k }
        field_name
      end

      def validate(record)
        @record = record
        check_fields_format
        @cc_type = get_cc_type
        validate_fields_presence
        validate_cc_number
        validate_cc_cvv
        validate_cc_month
        validate_cc_year
        validate_cc_expiry_date
      end

      private

      def validate_fields_presence
        [cc_number, cc_cvv, cc_month, cc_year, cc_owner].each do |field|
          add_error(field, :blank) if @record.public_send(field).blank?
        end
      end

      def validate_cc_number
        err = if @cc_type.nil?
                :invalid
              elsif !cc_providers.blank? && !cc_providers.include?(@cc_type)
                :not_supported
              end
        add_error(cc_number, err) if err
      end

      def validate_cc_cvv
        length = (@cc_type == :amex) ? 4 : 3
        unless !@cc_type.nil? && (/\A\d{#{length}}\z/).match(@record.public_send(cc_cvv))
          add_error(cc_cvv, :invalid)
        end
      end

      def validate_cc_month
        unless (/\A\d{2}\z/).match("%02d" % @record.public_send(cc_month).to_i) && @record.public_send(cc_month).to_i.between?(1, 12)
          add_error(cc_month, :invalid)
        end
      end

      def validate_cc_year
        unless (/\A\d{2}\z/).match(@record.public_send(cc_year)) && (@record.public_send(cc_year).to_i >= Date.today.year-2000)
          add_error(cc_year, :invalid)
        end
      end

      def validate_cc_expiry_date
        if (@record.errors.messages.keys & [cc_year, cc_month]).empty?
          year = "20#{@record.public_send(cc_year)}".to_i
          month = @record.public_send(cc_month).to_i
          date = Date.new(year, month).next_month.prev_day
          if date < Date.today
            field = if date.year < Date.today.year
                      cc_year
                    else
                      cc_month
                    end
            add_error(field, :invalid)
          end
        end
      end

      def add_error(field, message)
        @record.errors.add(field, error_message(field, message)) if @record.errors[field].blank?
      end

      def get_cc_type
        opt_cc_type = Optional.new(PROVIDERS.find { |_, regex| regex.match(@record.public_send(cc_number)) })
        opt_cc_type.and_then { |o| Optional.new(o.first) }.value
      end

      def error_message(field, message)
        opt_msg = Optional.new(custom_messages[field])
        opt_msg.and_then { |o| Optional.new(o[message]) }.value || translate_error(message)
      end

      def translate_error error
        ::I18n.t("errors.messages.#{error}")
      end

      def check_fields_format
        invalid_attr = [cc_number, cc_cvv, cc_month, cc_year, cc_owner].find do |attr|
          !@record.public_send(attr).is_a?(NilClass) && !@record.public_send(attr).is_a?(String)
        end
        if invalid_attr
          raise CCTypeError, "#{invalid_attr} is a #{@record.public_send(invalid_attr).class}, String expected."
        end
      end
    end

    module HelperMethods
      def validate_credit_card_fields(options={})
        validates_with DaftCcValidator, options
      end
    end
  end
end
