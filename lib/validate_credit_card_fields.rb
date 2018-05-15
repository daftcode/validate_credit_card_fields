class CCTypeError < StandardError; end

require 'validate_credit_card_fields/version'
require 'date'
require 'active_support/core_ext/object/try'

module ActiveModel
  module Validations

    class CreditCardFieldsValidator < Validator
      ERROR_TYPES = [:invalid, :blank, :not_supported]

      PROVIDERS = {
        visa: /^4[0-9]{12}(?:[0-9]{3})?$/,
        master_card: /^5[1-5]\d{14}$|^(222[1-9]|22[3-9]\d|2[3-6]\d{2}|27[01]\d|2720)\d{12}$/,
        maestro: /^(?:5[0678]\d\d|6304|6390|67\d\d)\d{8,15}$/,
        diners_club: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
        amex: /^3[47][0-9]{13}$/,
        discover: /^6(?:011|5[0-9]{2})[0-9]{12}$/,
        jcb: /^(?:2131|1800|35\d{3})\d{11}$/,
        solo: /(^(6334)[5-9](\d{11}$|\d{13,14}$)) |(^(6767)(\d{12}$|\d{14,15}$))/,
        china_union: /^62[0-5]\d{13,16}$/,
        dankort: /^5019\d{12}$/
      }

      attr_accessor :options, :cc_number, :cc_cvv, :cc_month,
                    :cc_year, :cc_owner, :cc_providers, :cc_type, :custom_messages,
                    :cc_first_name, :cc_last_name, :using_owner

      def initialize(options={})
        @options = options
        @custom_messages = {}
        @cc_number = init_option(:number, :cc_number)
        @cc_cvv = init_option(:cvv, :cc_cvv)
        @cc_month = init_option(:month, :cc_month)
        @cc_year = init_option(:year, :cc_year)
        @cc_providers = options[:providers]
        @using_owner = !options[:owner].nil? || options[:first_name].nil? || options[:last_name].nil?
        if @using_owner
          @cc_owner = init_option(:owner, :cc_owner)
        else
          @cc_first_name = init_option(:first_name, :cc_first_name)
          @cc_last_name = init_option(:last_name, :cc_last_name)
        end
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

      def validated_fields
        [cc_number, cc_cvv, cc_month, cc_year] + (using_owner ? [cc_owner] : [cc_first_name, cc_last_name])
      end      

      def validate_fields_presence
        validated_fields.each do |field|
          add_error(field, :blank) if @record.public_send(field).blank?
        end
      end

      def validate_cc_number
        err = if @cc_type.nil? || !luhn_algorithm_valid?
                :invalid
              elsif !cc_providers.blank? && !cc_providers.include?(@cc_type)
                :inclusion
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

      def luhn_algorithm_valid?
        return true if @cc_type == :china_union
        s1 = s2 = 0
        get_cc_number.to_s.reverse.chars.each_slice(2) do |odd, even|
          s1 += odd.to_i
          double = even.to_i * 2
          double -= 9 if double >= 10
          s2 += double
        end
        (s1 + s2) % 10 == 0
      end

      def add_error(field, message)
        @record.errors.add(field, message, message: error_message(field, message)) if @record.errors[field].blank?
      end

      def get_cc_type
        PROVIDERS.find{ |_, regex| regex.match(get_cc_number) }.try(:first)
      end

      def get_cc_number
        @record.public_send(cc_number).try(:delete, ' ')
      end

      def error_message(field, message)
        custom_messages[field].try(:[], message) || translate_error(message)
      end

      def translate_error error
        ::I18n.t("errors.messages.#{error}")
      end

      def check_fields_format
        invalid_attr = validated_fields.find do |attr|
          !@record.public_send(attr).is_a?(NilClass) && !@record.public_send(attr).is_a?(String)
        end
        if invalid_attr
          raise CCTypeError, "#{invalid_attr} is a #{@record.public_send(invalid_attr).class}, String expected."
        end
      end
    end

    module HelperMethods
      def validate_credit_card_fields(options={})
        validates_with CreditCardFieldsValidator, options
      end
    end
  end
end
