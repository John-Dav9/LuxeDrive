# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Car.destroy_all
User.destroy_all
User.create(first_name: "John", last_name: "David", email: "john@mail.com", password: "password")

cars = [
  {brand: "Lamborghini", category: "SUV",   model: "Urus awd", year: 2021, adress: "Paris", price: 1200, status: "available", user: User.first },
  { brand: "BMW", category: "SUV", model: "X5 xDrive40i", year: 2022, adress: "Nice", price: 7000, status: "available", user: User.last },
  {brand: "Koegnigsegg", category: "Hypercar",  model: "Regera", year: 2019, adress: "Lyon", price: 10000, status: "available", user: User.first }
]

cars.each do |car_data|
  Car.find_or_create_by!(user: car_data[:user]) do |car|
    car.brand = car_data[:brand]
    car.category = car_data[:category]
    car.model = car_data[:model]
    car.year = car_data[:year]
    car.adress = car_data[:adress]
    car.price = car_data[:price]
    car.status = car_data[:status]
  end
end

puts "Cars created!"







