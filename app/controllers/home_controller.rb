class HomeController < ApplicationController
  def index
    render json: {
      message: 'Wellcome!'
    }
  end
end
