module DaftCcValidator
  class Railtie < Rails::Railtie
    initializer 'daft_cc_validator.initialize' do
      p 'ActiveSupport.on_load(:active_model)'
      ActiveSupport.on_load(:active_model) do
        ActiveModel::Validations.send :include, DaftCcValidator
      end
    end
  end
end
