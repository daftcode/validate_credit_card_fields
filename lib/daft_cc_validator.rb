require 'daft_cc_validator/version'

module ActiveModel
  module Validations

  	class DaftCcValidator < Validator

  	  PROVIDERS = {
  	    visa: /^4[0-9]{12}(?:[0-9]{3})?$/,
  	    master_card: /^5[1-5][0-9]{14}$/,
  	    maestro: /(^6759[0-9]{2}([0-9]{10})$)|(^6759[0-9]{2}([0-9]{12})$)|(^6759[0-9]{2}([0-9]{13})$)/,
  	    diners_club: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
  	    amex: /^3[47][0-9]{13}$/,
  	    discover: /^6(?:011|5[0-9]{2})[0-9]{12}$/,
  	    jcb: /^(?:2131|1800|35\d{3})\d{11}$/
  	  }

  	  attr_accessor :cc_number, :cc_cvv, :cc_month,
        :cc_year, :cc_owner, :cc_providers, :cc_type

  	  def initialize(options={})
   		  self.cc_number = options[:number] 
	      self.cc_cvv = options[:cvv]
	      self.cc_month = options[:month]
	      self.cc_year = options[:year]
	      self.cc_owner = options[:owner]
	      self.cc_providers = options[:providers]
  	  end

  	  def validate(record)
  	  	@record = record
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
  	      add_error(field, 'can\'t be empty') if @record[field].blank?
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
  	    unless !@cc_type.nil? && /\d{#{length}}/.match(@record[cc_cvv])
  	      add_error(cc_cvv, 'is invalid')
  	    end
  	  end

  	  def validate_cc_month
  	    unless /\d{2}/.match(@record[cc_month]) && @record[cc_month].to_i.between?(1, 12)
  	      add_error(cc_month, 'is invalid')
  	    end
  	  end

  	  def validate_cc_year
  	    unless /\d{2}/.match @record[cc_year]
  	      add_error(cc_year, 'is invalid')
  	    end
  	  end

  	  def validate_cc_expiry_date
        if @record[cc_year] && @record[cc_month]
    	    year = "20#{@record[cc_year]}".to_i
    	    month = @record[cc_month].to_i
    	    date = Date.new(year, month).beginning_of_month
    	    if date.past?
    	      field = if date.year < Date.today.year
    	        cc_year
    	      else
    	        cc_month
    	      end
    	      add_error(field, 'date is past')
    	    end
        end
  	  end

  	  def add_error(field, message)
  	    @record.errors.add(field, message) if @record.errors[field].blank?
  	  end

  	  def get_cc_type
  	    PROVIDERS.find{ |_, regex| regex.match(@record[cc_number]) }.try(:first)
  	  end

  	end

  	module HelperMethods
  	  def validate_credit_card_fields(options={})
  	  	validates_with DaftCcValidator, options
      end
  	end
  end
end