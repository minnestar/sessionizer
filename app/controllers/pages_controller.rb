class PagesController < ApplicationController
  def home
    @recent_sessions = Session.all(:limit => 10, :order => 'created_at desc')
  end
end
