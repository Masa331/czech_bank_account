require 'active_model/validator'

module CzechBankAccount
  class BankAccountValidator < ActiveModel::Validator
    # http://www.cnb.cz/miranda2/export/sites/www.cnb.cz/cs/platebni_styk/pravni_predpisy/download/vyhl_169_2011.pdf
    # http://www.cnb.cz/miranda2/export/sites/www.cnb.cz/cs/platebni_styk/ucty_kody_bank/download/kody_bank_CR.pdf
    # http://www.cnb.cz/cs/platebni_styk/ucty_kody_bank/index.html

    WEIGHTS = [6, 3, 7, 9, 10, 5, 8, 4, 2, 1]
    KNOWN_CODES = ["0100", "0300", "0600", "0710", "0800", "2010", "2020", "2030", "2060", "2070", "2100", "2200", "2220", "2240", "2250", "2260", "2275", "2600", "2700", "3030", "3050", "3060", "3500", "4000", "4300", "5500", "5800", "6000", "6100", "6200", "6210", "6300", "6700", "6800", "7910", "7940", "7950", "7960", "7970", "7980", "7990", "8030", "8040", "8060", "8090", "8150", "8200", "8215", "8220", "8225", "8230", "8240", "8250", "8260", "8265", "8270", "8280", "8290", "8291", "8292", "8293", "8294"]

    def validate(record)
      if record.number.blank?
        record.errors.add(:base, :number_is_blank)
      end

      if record.bank_code.blank?
        record.errors.add(:base, :bank_code_is_blank)
      end

      validate_allowed_chars(record)
      validate_number(record)
      validate_bank_code(record)
    end

    private

    def validate_allowed_chars(record)
      return if record.number.blank?

      unless record.number.match?(/\A[0-9-]*\z/)
        record.errors.add :base, :number_includes_not_allowed_characters
      end
    end

    def validate_number(record)
      return if record.number.blank?
      return if record.number.count('-') > 1

      if record.number.include? '-'
        prefix, number = record.number.split '-'
      else
        prefix = nil
        number = record.number
      end

      if prefix && prefix.length > 6
        record.errors.add :base, :number_prefix_is_over_length_limit
        return
      end

      if number && (number.length < 2 || number.length > 10)
        record.errors.add :base, :number_is_over_or_under_length_limit
        return
      end

      if prefix && weighted_sum(prefix) % 11 != 0
        record.errors.add :base, :prefix_doesnt_pass_checksum
      end

      if number && weighted_sum(number) % 11 != 0
        record.errors.add :base, :number_doesnt_pass_checksum
      end
    end

    def validate_bank_code(record)
      unless KNOWN_CODES.include? record.bank_code
        record.errors.add :base, :unknown_bank_code
      end
    end

    def weighted_sum(number)
      normalized = number.rjust(10, '0')
      chars = normalized.chars.map(&:to_i)
      zipped = chars.zip WEIGHTS
      zipped.inject(0) { |acc, pair| acc + pair.first * pair.last }
    end
  end
end
