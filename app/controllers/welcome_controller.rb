class WelcomeController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json { render json: { message: "Welcome to the Library!" }, status: :ok }
    end
  end
end
