class CategoriesController < ApplicationController
  def show
    @category = Category.find(params[:id])
    @sessions = @category.sessions
  end
end
