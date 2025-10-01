module Api
  class BaseController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound do
      head :not_found
    end
  end
end
