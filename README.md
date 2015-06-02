# validate_credit_card_fields

Simple gem helpful in validating standard credit card forms.
Consists of validation for credit card, its cvv, expiration date and owner. Also allows provider limitation.

## Installation

Add this line to your application's Gemfile:

    gem 'daft_cc_validator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install daft_cc_validator

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

    :visa, :master_card, :maestro, :diners_club, :amex, :discover, :jcb

When a field name isn't presented, validator will use default values:

    :cc_number, :cc_cvv, :cc_month, :cc_year, :cc_owner


## Contributing

1. Fork it ( http://github.com/<my-github-username>/daft_cc_validator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
