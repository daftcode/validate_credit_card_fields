require 'active_record'

class User
  include ActiveModel::Validations

  attr_accessor  :credit_card_number, :credit_card_cvv, :credit_card_month,
    :credit_card_year, :credit_card_owner

  debugger

  validate_credit_card_fields  number: :credit_card_number, cvv: :credit_card_cvv, month: :credit_card_month,
    year: :credit_card_year, owner: :credit_card_owner, providers: [:amex, :visa]

end
