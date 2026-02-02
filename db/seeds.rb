# Seeds propres pour LuxeDrive avec système de rôles

puts "🧹 Nettoyage de la base de données..."
Booking.destroy_all
Car.destroy_all
User.destroy_all

puts "👤 Création des utilisateurs..."

# Super Admin
super_admin = User.create!(
  first_name: "Super", 
  last_name: "Admin", 
  email: "admin@luxedrive.com", 
  password: "password123",
  role: :super_admin
)
puts "✅ Super Admin créé: #{super_admin.email} / password123"

# Propriétaires de voitures (admin_client)
john = User.create!(
  first_name: "John", 
  last_name: "David", 
  email: "john@mail.com", 
  password: "password",
  role: :admin_client
)

clara = User.create!(
  first_name: "Clara", 
  last_name: "Barbé", 
  email: "clarabb@mail.com", 
  password: "password",
  role: :admin_client
)

# Visiteurs (clients)
visitor1 = User.create!(
  first_name: "Marie", 
  last_name: "Dupont", 
  email: "marie@mail.com", 
  password: "password",
  role: :visitor
)

visitor2 = User.create!(
  first_name: "Pierre", 
  last_name: "Martin", 
  email: "pierre@mail.com", 
  password: "password",
  role: :visitor
)

puts "✅ #{User.count} utilisateurs créés"

puts "\n🚗 Création des voitures..."

# Pricing rules (Europe market): base prices adjusted by season and city.
season_multiplier = case Date.today.month
                    when 6, 7, 8 then 1.25 # high season
                    when 5, 9 then 1.10 # shoulder season
                    else 1.00 # low season
                    end

city_multipliers = {
  "Paris" => 1.15,
  "Nice" => 1.20,
  "Lyon" => 1.00,
  "Bordeaux" => 0.95,
  "Marnes-La-Vallée" => 1.05
}.freeze

pricing_by_category = {
  "Berline" => (85..140),
  "SUV" => (110..180),
  "Luxe" => (220..420),
  "Sportive" => (350..750),
  "Électrique" => (90..180),
  "Cabriolet" => (180..320),
  "4x4" => (120..200)
}.freeze

cities = [
  "Paris, France",
  "Lyon, France",
  "Nice, France",
  "Bordeaux, France",
  "Marseille, France",
  "Toulouse, France",
  "Nantes, France",
  "Strasbourg, France",
  "Lille, France",
  "Montpellier, France",
  "Marnes-La-Vallée, France",
  "Cannes, France",
  "Geneva, Switzerland",
  "Zurich, Switzerland",
  "Milan, Italy",
  "Rome, Italy",
  "Barcelona, Spain",
  "Madrid, Spain",
  "Lisbon, Portugal",
  "Brussels, Belgium"
].freeze

fleet_catalog = {
  "Audi" => ["A3", "A4", "A6", "Q3", "Q5", "Q7", "Q8"],
  "BMW" => ["118i", "320i", "330e", "X1", "X3", "X5", "X6"],
  "Mercedes" => ["A180", "C200", "E200", "GLA 200", "GLC 220d", "GLE 350"],
  "Volkswagen" => ["Golf", "Passat", "Tiguan", "T-Roc"],
  "Peugeot" => ["208", "308", "3008", "508"],
  "Renault" => ["Clio", "Megane", "Captur", "Austral"],
  "Tesla" => ["Model 3", "Model Y", "Model S", "Model X"],
  "Porsche" => ["Macan", "Cayenne", "Panamera", "911 Carrera"],
  "Land Rover" => ["Range Rover Evoque", "Range Rover Sport", "Discovery"],
  "Lexus" => ["UX 250h", "NX 350h", "RX 450h"],
  "Volvo" => ["XC40", "XC60", "S90"],
  "Jaguar" => ["F-Pace", "XE", "XF"]
}.freeze

categories = pricing_by_category.keys.freeze

# Voitures de John et Clara
cars_data = [
  {brand: "Bentley", category: "Luxe", model: "Continental GTC", year: 2023, address: "Marnes-La-Vallée, France", base_price: 1900, status: true, user: john},
  {brand: "Audi", category: "Luxe", model: "Q8 Premium Plus", year: 2023, address: "Lyon, France", base_price: 250, status: true, user: john},
  {brand: "Lamborghini", category: "Sportive", model: "Urus AWD", year: 2021, address: "Paris, France", base_price: 1900, status: true, user: john},
  {brand: "BMW", category: "SUV", model: "X5 xDrive40i", year: 2022, address: "Nice, France", base_price: 650, status: true, user: clara},
  {brand: "Tesla", category: "Électrique", model: "Model S Plaid", year: 2023, address: "Bordeaux, France", base_price: 480, status: true, user: clara}
]

cars_data.each do |car_attrs|
  city = car_attrs[:address].split(",").first
  city_multiplier = city_multipliers.fetch(city, 1.0)
  base_price = car_attrs.delete(:base_price)
  car_attrs[:price] = (base_price * season_multiplier * city_multiplier).round
  Car.create!(car_attrs)
end

puts "\n🚙 Génération de la flotte..."

rng = Random.new(2026)
target_total_cars = 150
additional_cars = [target_total_cars - Car.count, 0].max

additional_cars.times do
  brand, models = fleet_catalog.to_a.sample(random: rng)
  model = models.sample(random: rng)
  category = categories.sample(random: rng)
  year = rng.rand(2018..2024)
  address = cities.sample(random: rng)
  base_price = rng.rand(pricing_by_category.fetch(category))

  city = address.split(",").first
  city_multiplier = city_multipliers.fetch(city, 1.0)
  price = (base_price * season_multiplier * city_multiplier).round

  Car.create!(
    brand: brand,
    category: category,
    model: model,
    year: year,
    address: address,
    price: price,
    status: rng.rand < 0.92,
    user: [john, clara].sample(random: rng)
  )
end

puts "✅ Flotte enrichie: #{Car.count} voitures"

puts "✅ #{Car.count} voitures créées"

puts "\n📅 Création de réservations exemples..."

Booking.create!(
  car: Car.first,
  user: visitor1,
  checkin_date: Date.today + 3.days,
  checkout_date: Date.today + 7.days,
  status: :pending,
  pickup_mode: "pickup",
  pickup_address: Car.first.address,
  pickup_time: "10:00",
  return_time: "18:00",
  drivers_count: 1,
  driver_age: 30,
  license_years: 10,
  premium_insurance: false,
  child_seat: false,
  gps: false,
  terms_accepted: true,
  deposit_card: true
)

Booking.create!(
  car: Car.second,
  user: visitor2,
  checkin_date: Date.today + 10.days,
  checkout_date: Date.today + 14.days,
  status: :accepted,
  pickup_mode: "delivery",
  pickup_address: "15 Rue de la Paix, Paris, France",
  pickup_time: "09:00",
  return_time: "17:30",
  drivers_count: 2,
  driver_age: 28,
  license_years: 9,
  premium_insurance: true,
  child_seat: false,
  gps: true,
  terms_accepted: true,
  deposit_card: true
)

puts "✅ #{Booking.count} réservations créées"

puts "\n🎉 Seed terminé avec succès!"
puts "\n📋 Récapitulatif:"
puts "  • Super Admin: admin@luxedrive.com / password123"
puts "  • Propriétaire 1: john@mail.com / password"
puts "  • Propriétaire 2: clarabb@mail.com / password"
puts "  • Visiteur 1: marie@mail.com / password"
puts "  • Visiteur 2: pierre@mail.com / password"
puts "\n  Total: #{User.count} utilisateurs, #{Car.count} voitures, #{Booking.count} réservations"
