FactoryBot.define do
  factory :book do
    title { "The Great Gatsby" }
    fee { Book::DEFAULT_FEE }
    available_copies { 5.00 }
  end
end