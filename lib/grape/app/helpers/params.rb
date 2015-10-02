module Grape::App::Helpers::Params

  # Scope declared params
  # @return [Hashie::Mash] declared params only
  def declared_params
    hash = declared(params, include_missing: false)
    hash.permit! if hash.respond_to?(:permit!)
    hash
  end

end
