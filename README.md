# CzechBankAccount [![Build Status](https://www.travis-ci.org/Masa331/czech_bank_account.svg?branch=master)](https://www.travis-ci.org/Masa331/czech_bank_account)

Czech bank accounts validations with official Czech National Bank algorithm.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'czech_bank_account'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install czech_bank_account


## Usage

Initialize `CzechBankAccount::Account` and call `validate` on it:
```
number = '36-6420840257' # bank account number with optional prefix but without bank code
bank_code = '0301' # separate bank code
account = CzechBankAccount::Account.new(number, bank_code)

account.validate # returns array with error symbols
#=> [:prefix_doesnt_pass_checksum, :unknown_bank_code]
```

Or use a shortcut which returns errors directly:
```
CzechBankAccount.validate('35-6420840257', '9999') # returns array with error symbols
#=> [:unknown_bank_code]
```


### Possible error symbols

1. `:number_is_empty`
2. `:bank_code_is_empty`
3. `:number_includes_not_allowed_characters`
4. `:number_prefix_is_over_length_limit`
5. `:number_is_over_or_under_length_limit`
6. `:prefix_doesnt_pass_checksum`
7. `:number_doesnt_pass_checksum`
8. `:unknown_bank_code`


### Usage in Rails

Prepare your own custom validation as per [Rails guide](https://guides.rubyonrails.org/active_record_validations.html#performing-custom-validations)


For example ActiveModel::Validator could look like following:
```
# app/validators/czech_bank_account_validator.rb
class CzechBankAccountValidator < ActiveModel::Validator
  def validate(record)
    errors = CzechBankAccount.validate(record.account_number, record.bank_code)
    errors.each { |e| record.errors.add(:base, e) }
  end
end
```

Then in model:
```
class Invoice < ApplicationRecord
  validates_with CzechBankAccountValidator
end
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Masa331/czech_bank_account.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Links


### Official docs for account validation algorithm

* http://www.cnb.cz/miranda2/export/sites/www.cnb.cz/cs/platebni_styk/pravni_predpisy/download/vyhl_169_2011.pdf
* http://www.cnb.cz/miranda2/export/sites/www.cnb.cz/cs/platebni_styk/ucty_kody_bank/download/kody_bank_CR.pdf
* http://www.cnb.cz/cs/platebni_styk/ucty_kody_bank/index.html
