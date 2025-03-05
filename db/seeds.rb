# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require_relative "../app/services/create_book_loan"


USERS = [
  ActiveSupport::HashWithIndifferentAccess.new(
    email: "john@doe.com",
    password: "Password1234",
    balance: 8.9
  ),
  ActiveSupport::HashWithIndifferentAccess.new(
    email: "jane@smith.com",
    password: "Password1234",
    balance: 10.6
  ),
  ActiveSupport::HashWithIndifferentAccess.new(
    email: "adam@lee.com",
    password: "Password1234",
    balance: 5.0
  )
]


["Frankenstein", "Rich Dad Poor Dad", "The Great Gatsby", "The Catcher in the Rye", "The Alchemist"].each do |book_title|
  Book.find_or_create_by!(title: book_title, available_copies: 5, fee: Book::DEFAULT_FEE)
end

USERS.each do |user|
  User.create(**user)
end

CreateBookLoan.new(user: User.find_by_email("john@doe.com"), book: Book.find_by_title("Rich Dad Poor Dad")).call
CreateBookLoan.new(user: User.find_by_email("adam@lee.com"), book: Book.find_by_title("Frankenstein")).call

puts "Seeds created successfully!"