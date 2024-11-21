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

# cars = [
  Car.create({brand: "Bentley", category: "Hypercar",  model: "Continental GTC awd", year: 2023, address: "Marnes-La-Valley", photo_url: "https://img.jamesedition.com/listing_images/2024/11/20/08/28/54/03d36370-49e3-4204-b12b-13972e31774d/je/1900xxs.jpg", price: 660, status: "available", user: User.first })
  Car.create({brand: "Audi", category: "Hypercar",  model: "Q8 Premium Plus", year: 2023, address: "Lyon", photo_url: "https://img.jamesedition.com/listing_images/2024/11/15/15/53/32/121afb83-8754-4f06-9027-cd68f4d96bee/je/1900xxs.jpg", price: 1000, status: "available", user: User.first })
  Car.create({brand: "Lamborghini", category: "SUV",   model: "Urus awd", year: 2021, address: "Paris", photo_url: "https://img.jamesedition.com/listing_images/2024/11/20/08/28/54/f6920e67-0c51-4cce-a8e7-a729b36c2dc7/je/1900xxs.jpg",  price: 520, status: "available", user: User.first })
  Car.create({brand: "BMW", category: "SUV", model: "X5 xDrive40i", year: 2022, address: "Nice", photo_url: "https://img.jamesedition.com/listing_images/2024/11/15/15/53/32/f1fb1488-3a0d-4c80-be4d-d89ea8f5f14b/je/1900xxs.jpg", price: 715, status: "available", user: User.last })
  Car.create({brand: "Koegnigsegg", category: "Hypercar",  model: "Regera", year: 2019, address: "Lyon", photo_url: "https://img.jamesedition.com/listing_images/2024/10/01/14/46/52/3d2652e9-7bfc-43de-b6a1-a61fd0c6bcb2/je/1900xxs.jpg", price: 896, status: "available", user: User.first })
  Car.create({brand: "ferrarri", category: "Hypercar",  model: "Purosangue", year: 2024, address: "Lille", photo_url: "https://img.jamesedition.com/listing_images/2024/11/19/14/00/31/b9493843-7256-469b-b59d-da7c00df4a13/je/1900xxs.jpg", price: 375, status: "available", user: User.first })
  Car.create({brand: "mercedes-benz", category: "Hypercar",  model: "280", year: 1969, address: "Lyon", photo_url: "https://img.jamesedition.com/listing_images/2024/11/20/16/56/42/db9130d3-dee3-472f-84c2-4ee3c4d05846/je/1900xxs.jpg", price: 279, status: "available", user: User.first })
  Car.create({brand: "Ford", category: "SUV", model: "Ford Mustang EcoBoost Premium Coupe 2D", year: 2024, address: "Nice", photo_url: "https://img.jamesedition.com/listing_images/2024/11/20/16/56/42/01ca5712-bed5-4545-9438-30dac57549de/je/1900xxs.jpg", price: 700, status: "available", user: User.last })
  Car.create({brand: "BMW", category: "SUV",  model: "7 Series 760i xDrive Sedan 4D", year: 2023, address: "Nanteuil", photo_url: "https://img.jamesedition.com/listing_images/2024/11/21/11/19/45/d3372bba-39b3-45c2-a63d-ea22985f1311/je/1900xxs.jpg", price: 1000, status: "available", user: User.first })
  Car.create({brand: "porshe", category: "SUV",  model: "Cayenne", year: 2020, address: "Lyon", photo_url: "https://img.jamesedition.com/listing_images/2024/11/21/11/19/45/138fff12-9746-425b-8aae-c41253c965b6/je/1900xxs.jpg", price: 899, status: "available", user: User.first })
  Car.create({brand: "bugatti", category: "Hypercar",  model: "Veyron", year: 2009, address: "Eperney", photo_url: "https://img.jamesedition.com/listing_images/2024/11/18/12/55/11/53175852-a17e-41e4-84a6-3f47e72d69ab/je/1900xxs.jpg", price: 1000, status: "available", user: User.first })
  Car.create({brand: "porshe", category: "Hypercar",  model: "Taycan Sedan 4D", year: 2021, address: "Marseille", photo_url: "https://img.jamesedition.com/listing_images/2024/11/21/11/19/45/2209a0ca-840c-4adb-9da4-c22e2d232e5e/je/1900xxs.jpg", price: 958, status: "available", user: User.first })
  Car.create({brand: "BMW", category: "SUV",  model: "M3 Sedan 4D", year: 2019, address: "Lyon", photo_url: "https://img.jamesedition.com/listing_images/2024/11/20/16/56/42/d585130e-48f2-4f33-9a4e-cdf9478f35cd/je/1900xxs.jpg", price: 1000, status: "available", user: User.first })
  Car.create({brand: "porshe", category: "Hypercar",  model: "911 991430", year: 2018, address: "London", photo_url: "https://img.jamesedition.com/listing_images/2024/11/20/16/56/42/cc575da5-f9e1-49e0-a2fa-2a78c7601c6a/je/1900xxs.jpg", price: 1000, status: "available", user: User.first })
  Car.create({brand: "Mercedes-benz", category: "SUV",  model: "AMG", year: 2021, address: "Chateau-Thierry", photo_url: "https://img.jamesedition.com/listing_images/2024/11/20/16/56/40/4f1e9904-eaf6-4d67-be0b-98cef607140a/je/1900xxs.jpg", price: 934, status: "available", user: User.first })
# ] 

# cars.each do |car_data|
#   Car.find_or_create_by!(user: car_data[:user]) do |car|
#     car.brand = car_data[:brand]
#     car.category = car_data[:category]
#     car.model = car_data[:model]
#     car.year = car_data[:year]
#     car.address = car_data[:address]
#     car.photo_url = car_data[:photo_url]
#     car.price = car_data[:price]
#     car.status = car_data[:status]
#   end
# end

puts "Cars created!"







