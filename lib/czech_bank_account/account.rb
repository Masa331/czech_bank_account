module CzechBankAccount
  class Account
    WEIGHTS = [6, 3, 7, 9, 10, 5, 8, 4, 2, 1]

    attr_reader :number, :bank_code

    def initialize(number = nil, bank_code = nil)
      @number, @bank_code = number.to_s, bank_code.to_s
    end

    def validate
      errors = []

      if number.empty?
        errors << :number_is_empty
      end

      if bank_code.empty?
        errors << :bank_code_is_empty
      end

      validate_allowed_chars(errors)
      validate_number(errors)
      validate_bank_code(errors)

      errors
    end

    private

    def validate_allowed_chars(errors)
      unless number.match?(/\A[0-9-]*\z/)
        errors << :number_includes_not_allowed_characters
      end
    end

    def validate_number(errors)
      return if number.empty?
      return if number.count('-') > 1

      if number.include? '-'
        prefix, base = number.split '-'
      else
        prefix = nil
        base = number
      end

      if prefix && prefix.length > 6
        errors << :number_prefix_is_over_length_limit
        return
      end

      if base && (base.length < 2 || base.length > 10)
        errors << :number_is_over_or_under_length_limit
        return
      end

      if prefix && weighted_sum(prefix) % 11 != 0
        errors << :prefix_doesnt_pass_checksum
      end

      if number && weighted_sum(base) % 11 != 0
        errors << :number_doesnt_pass_checksum
      end
    end

    def validate_bank_code(errors)
      unless CzechBankAccount::KNOWN_BANK_CODES.include? bank_code
        errors << :unknown_bank_code
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
