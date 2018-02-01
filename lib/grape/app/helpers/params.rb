module Grape::App::Helpers::Params

  # Scope declared params
  # @return [ActiveSupport::HashWithIndifferentAccess] declared params only
  def declared_params
    declared(params, include_missing: false)
  end

end
