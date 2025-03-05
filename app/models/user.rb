class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :book_loans
  has_many :books, through: :book_loans
  validates :balance, numericality: { greater_than_or_equal_to: 0 }
end
