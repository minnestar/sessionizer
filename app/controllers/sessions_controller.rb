class SessionsController < ApplicationController
  make_resourceful do
    actions :index, :show, :new, :create, :update
  end
end
