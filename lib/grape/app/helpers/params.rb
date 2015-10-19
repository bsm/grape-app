module Grape::App::Helpers::Params

  # Scope declared params
  # @return [Hashie::Mash] declared params only
  def declared_params
    declared(params, include_missing: false)
  end

end
