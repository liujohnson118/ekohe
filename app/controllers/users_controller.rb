class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update]

  def index
    @users = User.all

    respond_to do |format|
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.json { render json: @user }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "update-response",
            partial: "users/update_response",
            locals: { user: @user }
          )
        end
      end
    else
      respond_to do |format|
        format.json { render json: @user.errors, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "update-response",
            partial: "users/update_response",
            locals: { errors: @user.errors.full_messages }
          )
        end
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:balance)
  end
end
