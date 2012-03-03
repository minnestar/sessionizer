class PagesController < ApplicationController
  def home
    @current_event = Event.current_event
    @events = Event.all(:conditions => ["id != ?", @current_event], :order => 'date asc')
    
    @recent_sessions = @current_event.sessions.all(:limit => 10, :order => 'created_at desc')
    @development = Category.find_by_name('Development')
    @design = Category.find_by_name('Design')
    @hardware = Category.find_by_name('Hardware')
    @startups = Category.find_by_name('Startups')
    @other = Category.find_by_name('Other')
  end
end
