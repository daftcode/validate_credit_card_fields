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
      validate :validate_ccf
    end
  end

  module ClassMethods
    
    def validate_credit_card_fields(options={})
      @@cc_number = options[:number]
      @@cc_cvv = options[:cvv]
      @@cc_month = options[:month]
      @@cc_year = options[:year]
      @@cc_owner = options[:owner]
      @@cc_providers = options[:providers]
    end
  end

  def validate_ccf
    validate_cc_number
  end

  private

  def validate_cc_number
    self.class::PROVIDERS.values.select{ |regex| regex.match @@cc_number }
  end
end