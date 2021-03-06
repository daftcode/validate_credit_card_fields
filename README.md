# validate_credit_card_fields

Simple gem helpful in validating standard credit card forms.
Consists of validation for credit card, its cvv, expiration date and owner. Also allows provider limitation.

## Installation

Add this line to your application's Gemfile:

    gem 'validate_credit_card_fields'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install validate_credit_card_fields

## Usage

Inside your model:

    validate_credit_card_fields number: :your_cc_number_field,
                                cvv: :your_ccv_field,
                                month: :your_cc_month_field,
                                year: :your_cc_year_field,
                                owner: :your_cc_owner_field,
                                providers: [:amex, :visa]

In place of `:your_something_field` place keys representing desired value in your model.

`providers` are used to specify provider limitations. Supply it with a list of **supported** providers (those you want to be valid). Leaving it blank will allow any of the accepted providers below:

    :visa, :master_card, :maestro, :diners_club, :amex, :discover, :jcb, :solo, :china_union, :dankort

When a field name isn't presented, validator will use default values:

    :cc_number, :cc_cvv, :cc_month, :cc_year, :cc_owner
    
Now possible to validate credit card owner using first and last names, for example:
    
    validate_credit_card_fields first_name: :your_first_name_field,
                                last_name: :your_last_name_field

If both `:first_name` and `:last_name` keys are provided, those two fields will be validated, otherwise it'll fall back to `:owner`.


## Contributing

1. Fork it ( http://github.com/<my-github-username>/validate_credit_card_fields/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
