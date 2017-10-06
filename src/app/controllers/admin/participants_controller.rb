# frozen_string_literal: true

# View, edit and create users
class Admin::ParticipantsController < Admin::AdminController
  load_resource
  respond_to :html

  def index
    @participants ||= Participant.all
    respond_with(@participants)
  end

  def new
    respond_with(@participant)
  end

  def edit
    respond_with(@participant)
  end

  def update
    if @participant.update(participant_params)
      flash[:success] = 'Participant updated.'
      redirect_to admin_participants_path
    else
      render :edit
    end
  end

  def create
    # Prevent hitting a uniqueness constraint on email
    @participant.email = nil if @participant.email.blank?
    if @participant.save(validate: false) # allow not setting an email address
      flash[:success] = 'Participant created.'
      redirect_to admin_participants_path
    else
      render :edit
    end
  end

  private

  def participant_params
    params.require(:participant).permit(:name, :email, :bio)
  end
end
