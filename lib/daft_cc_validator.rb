require "daft_cc_validator/version"

module DaftCcValidator

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
    validate_cc_number
    validate_cc_owner
    validate_cc_expiry_date
  end

  private

  def validate_cc_number
    provider = cc_type
    if provider.nil?
      self.errors.add(self.class.cc_number, 'credit card number is invalid')
    elsif !self.class.cc_providers.blank? && !self.class.cc_providers.include?(provider)
      self.errors.add(self.class.cc_number, 'provider is not supported')
    end
  end

  def validate_cc_owner
    if read_attribute(self.class.cc_owner).blank?
      errors.add(self.class.cc_owner, 'owner can\'t be blank')
    end
  end

  def validate_cc_expiry_date
    year = read_attribute(self.class.cc_year)
    month = read_attribute(self.class.cc_month)
    if Date.new(year, month).end_of_month.past?
      errors.add(self.class.cc_owner, 'date is past')
    end
  end


  def cc_type
    PROVIDERS.find{ |provider, regex| regex.match(read_attribute(self.class.cc_number)) }.first
  end
end