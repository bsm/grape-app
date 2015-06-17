module Grape::App::Helpers::Params

  # Scope declared params
  # @return [Hashie::Mash] decalred params only
  def declared_params
    declared(params, include_missing: false)
  end

end
