class Api::V1::ItemsController < ApplicationController
  def index
  end
  def create
    item = Item.new amount: 1
    if item.save
      render json: {resource: item}
    else
      render json: {errors: item.errors}
    end
  end
end
