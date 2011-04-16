class CategoriesController < ApplicationController
  def show
    @category = Category.find(params[:id])
    @sessions = @category.sessions.for_current_event
  end
end
