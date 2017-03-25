# -*- coding: utf-8 -*-
class SessionsController < ApplicationController

  load_resource only: [:new, :show, :edit, :create, :update]
  before_action :verify_session, only: [:new, :create, :update, :edit]
  before_action :verify_owner, only: [:update, :edit]

  respond_to :html
  respond_to :json, only: :index

  def show
    @similar_sessions = []
    @similar_sessions = @session.recommended_sessions
    respond_with(@session)
  end

  def new
    respond_with(@session)
  end

  def edit
    respond_with(@session)
  end

  def update
    @session.update(session_params)
    respond_with(@session)
  end

  def index
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
    else
      @event = Event.current_event
    end

    respond_to do |format|
      format.json do
        render json: (
          cache ['sessions.json'] + event_schedule_cache_key(@event), expires_in: 10.minutes do
            SessionsJsonBuilder.new.to_json(
              Session.preload_attendance_counts(
                sessions_for_event(@event)))
          end
        )
      end
      format.html do
        @sessions = sessions_for_event(@event)
      end
    end
  end

  def create
    @session.attributes = session_params
    @session.participant = current_participant
    @session.event = Event.current_event

    if @session.save
      flash[:notice] = "Thanks for adding your session."
      redirect_to @session
    else
      render :action => 'new'
    end
  end

  STOP_WORDS = Set.new(['session', 'etc', 'just', 'presentation', 'get', 'discussion'])

  def words
    @sessions = Event.current_event.sessions
    @words = @sessions.map(&:description).
      map { |desc| view_context.markdown(desc) }.
      map { |md| view_context.strip_tags(md) }.
      map(&:downcase).
      join(" ").
      gsub(/[.*,-?()+!"•—%]/, '').
      split(/\s+/).
      reject { |w| STOP_WORDS.include?(w) }.
      join(" ")
  end

  def export
    @sessions = Event.current_event.sessions.all.order('lower(title) asc')
    render :layout => 'export'
  end

  def popularity
    @sessions = Event.current_event.sessions.with_attendence_count.all.order("COALESCE(attendence_count, 0) desc")
    render :layout => 'export'
  end

  private

  def session_params
    params.require(controller_name.singularize).permit(:title, :description, :level_id, :name, :email, :category_ids => [])
  end

  def verify_owner
    redirect_to @session if @session.participant != current_participant
  end

private

  def sessions_for_event(event)
    @event.sessions
      .includes(:presenters, :categories, :participant, :room, :timeslot, :level)
      .order('created_at desc')
      .distinct
  end

end
