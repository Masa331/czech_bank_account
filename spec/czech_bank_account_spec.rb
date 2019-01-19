require 'spec_helper'

RSpec.describe CzechBankAccount::Account do
  describe '#validate' do
    it 'validates that number is present' do
      account = CzechBankAccount::Account.new(nil, nil)

      errors = account.validate

      expect(errors).to include(:number_is_empty)
    end

    it 'validates that bank code is present' do
      account = CzechBankAccount::Account.new(nil, nil)

      errors = account.validate

      expect(errors).to include(:bank_code_is_empty)
    end

    it 'validates that bank code is known' do
      account = CzechBankAccount::Account.new(nil, '9999')

      errors = account.validate

      expect(errors).to include(:unknown_bank_code)
    end

    it 'validates that number include only allowed characters' do
      account = CzechBankAccount::Account.new('abc', nil)

      errors = account.validate

      expect(errors).to include(:number_includes_not_allowed_characters)
    end

    it 'validates that number prefix is not over length limit' do
      account = CzechBankAccount::Account.new('123456789-1234', nil)

      errors = account.validate

      expect(errors).to include(:number_prefix_is_over_length_limit)
    end

    it 'validates that number is not over length limit' do
      account = CzechBankAccount::Account.new('123456789012345', nil)

      errors = account.validate

      expect(errors).to include(:number_is_over_or_under_length_limit)
    end

    it 'validates that number is not under length limit' do
      account = CzechBankAccount::Account.new('1', nil)

      errors = account.validate

      expect(errors).to include(:number_is_over_or_under_length_limit)
    end

    it 'validates that prefix passes checksum test' do
      account = CzechBankAccount::Account.new('36-64', nil)

      errors = account.validate

      expect(errors).to include(:prefix_doesnt_pass_checksum)
    end

    it 'validates that base passes checksum test' do
      account = CzechBankAccount::Account.new('65', nil)

      errors = account.validate

      expect(errors).to include(:number_doesnt_pass_checksum)
    end

    it "valid bank accounts don't contain errors" do
      account = CzechBankAccount::Account.new('35-6420840257', '0100')
      expect(account.validate).to be_empty

      account = CzechBankAccount::Account.new('6420840257', '0100')
      expect(account.validate).to be_empty
    end
  end

  it 'shortcut works' do
    errors = CzechBankAccount.validate('36-64', nil)

    expect(errors).to include(:prefix_doesnt_pass_checksum)
  end
end
