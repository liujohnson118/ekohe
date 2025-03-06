class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :account_status]

  def index
    @users = User.all

    render json: @users
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def account_status
    render json: {
      balance: @user.balance,
      book_loans: @user.book_loans.includes(:book).map do |loan|
        {
          id: loan.id,
          book_id: loan.book_id,
          book_title: loan.book.title,
          borrowed_at: loan.borrowed_at,
          returned_at: loan.returned_at
        }
      end
    }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:balance)
  end
end
