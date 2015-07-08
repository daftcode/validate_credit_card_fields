require 'active_model'

class NamedUser
  include ActiveModel::Validations

  attr_accessor  :credit_card_number, :credit_card_cvv, :credit_card_month,
    :credit_card_year, :first_name, :last_name

  validate_credit_card_fields  number: :credit_card_number,
                               cvv: :credit_card_cvv,
                               month: { field: :credit_card_month },
                               year: :credit_card_year,
                               first_name: :first_name,
                               last_name: :last_name,
                               providers: [:amex, :visa]

  def [](key)
    send(key)
  end

end
