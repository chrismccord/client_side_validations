module ClientSideValidations::ActiveModel
  module Numericality

    OPTION_MAP = {}

    def self.included(base)
      OPTION_MAP.merge!(base::CHECKS.keys.inject({}) { |hash, key| hash.merge!(key => key) })
      OPTION_MAP.merge!(:numericality => :not_a_number, :only_integer => :not_an_integer)
    end

    def client_side_hash(model, attribute)
      except_options = ::ActiveModel::Errors::CALLBACKS_OPTIONS - [:on] + [:message]
      extra_options = options.except(*except_options).reject { |key, value| key == :only_integer && !value }
      keys = [:numericality] | (extra_options.keys - [:message, :on])
      filtered_options = options.except(*self.class::RESERVED_OPTIONS)
      messages = keys.inject({}) do |hash, key|
        count = extra_options[key]
        hash.merge!(key => model.errors.generate_message(attribute, OPTION_MAP[key], filtered_options.merge(:count => count)))
      end

      { :messages => messages }.merge(extra_options)
    end

  end
end

