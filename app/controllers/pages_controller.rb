class PagesController < ApplicationController
  def home
    @current_event = Event.current_event
    
    @recent_sessions = @current_event.sessions.all(:limit => 10, :order => 'created_at desc')
    @development = Category.where(name:'Development').first
    @design = Category.where(name:'Design').first
    @hardware = Category.where(name:'Hardware').first
    @startups = Category.where(name:'Startups').first
    @other = Category.where(name:'Other').first
  end
end
