# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require_relative "../app/services/borrow_book"
require_relative "../app/services/return_book"


USERS = [
  ActiveSupport::HashWithIndifferentAccess.new(
    email: "john@doe.com",
    password: "Password1234",
    balance: 10.0
  ),
  ActiveSupport::HashWithIndifferentAccess.new(
    email: "jane@smith.com",
    password: "Password1234",
    balance: 10.0
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

BorrowBook.new(user: User.find_by_email("john@doe.com"), book: Book.find_by_title("Rich Dad Poor Dad")).call
BorrowBook.new(user: User.find_by_email("adam@lee.com"), book: Book.find_by_title("Frankenstein")).call

ReturnBook.new(book_loan: BookLoan.find_by(book: Book.find_by_title("Rich Dad Poor Dad"))).call

# Expect john@doe to have 8.75 balance since he has borrowed and returned the book
# Expect jane@smith to have 10.0 balance since she has not borrowed any book
# Expect adam@lee to have 5.0 balance since he has borrowed a book but not returned yet
puts "Users and their balances:"
puts User.all.map { |user| "#{user.email}: #{user.balance}" }

# All books expect Frankenstein to have 5 available copies. Frankenstein should have 4. 
puts "Books and their available copies:"
puts Book.all.map { |book| "#{book.title}: #{book.available_copies}" }

# Book loan for john@doe should have been returned
# Book loan for adam@lee should not have been returned
puts "Book loans:"
puts BookLoan.all.map { |book_loan| "#{book_loan.user.email} borrowed #{book_loan.book.title} at #{book_loan.borrowed_at}, returned at #{book_loan.returned_at}" }