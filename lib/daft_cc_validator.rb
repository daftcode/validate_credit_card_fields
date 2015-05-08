require 'daft_cc_validator/version'
require 'rails'

module DaftCcValidator

  require 'daft_cc_validator/railtie' if defined?(Rails)

  PROVIDERS = {
    visa: /^4[0-9]{12}(?:[0-9]{3})?$/,
    master_card: /^5[1-5][0-9]{14}$/,
    maestro: /(^6759[0-9]{2}([0-9]{10})$)|(^6759[0-9]{2}([0-9]{12})$)|(^6759[0-9]{2}([0-9]{13})$)/,
    diners_club: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
    amex: /^3[47][0-9]{13}$/,
    discover: /^6(?:011|5[0-9]{2})[0-9]{12}$/,
    jcb: /^(?:2131|1800|35\d{3})\d{11}$/
  }

  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      cattr_accessor :cc_number, :cc_cvv, :cc_month,
        :cc_year, :cc_owner, :cc_providers
      attr_accessor :cc_type
      validate :validate_ccf
    end
  end

  module ClassMethods
    def validate_credit_card_fields(options={})
      self.cc_number = options[:number]
      self.cc_cvv = options[:cvv]
      self.cc_month = options[:month]
      self.cc_year = options[:year]
      self.cc_owner = options[:owner]
      self.cc_providers = options[:providers]
    end
  end

  def validate_ccf
    @cc_type = get_cc_type
    validate_fields_presence
    validate_cc_number
    validate_cc_cvv
    validate_cc_expiry_date
  end 

  private

  def validate_fields_presence
    [cc_number, cc_cvv, cc_month, cc_year, cc_owner].each do |field|
      add_error(field, 'can\'t be empty') if read_attribute(field).blank?
    end
  end

  def validate_cc_number
    err = if @cc_type.nil?
      'is invalid'
    elsif !cc_providers.blank? && !cc_providers.include?(@cc_type)
      'provider is not supported'
    end
    add_error(cc_number, err) if err
  end

  def validate_cc_cvv
    length = (@cc_type == :amex) ? 4 : 3
    if @cc_type.nil? || /\d{#{length}}/.match(cc_cvv)
      add_error(cc_cvv, 'is invalid')
    end
  end

  def validate_cc_expiry_date
    year = "20#{read_attribute(cc_year)}".to_i
    month = read_attribute(cc_month).to_i
    date = Date.new(year, month).end_of_month
    if date.past?
      field = if date.year < Date.today.year
        cc_year
      else
        cc_month
      end
      add_error(field, 'date is past')
    end
  end

  def add_error(field, message)
    errors.add(field, message) if errors[field].blank?
  end

  def get_cc_type
    PROVIDERS.find{ |_, regex| regex.match(read_attribute(cc_number)) }.try(:first)
  end

end