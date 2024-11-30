module Usecase
  extend ActiveSupport::Concern

  included do
    def initialize(**params)
      params.each { |k, v| self.instance_variable_set("@#{k}", v) }
    end

    def execute
      raise NotImplementedError
    end
  end
end
