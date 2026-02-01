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

# Voitures de John et Clara
cars_data = [
  {brand: "Bentley", category: "Luxe", model: "Continental GTC", year: 2023, address: "Marnes-La-Vallée, France", price: 660, status: true, user: john},
  {brand: "Audi", category: "Luxe", model: "Q8 Premium Plus", year: 2023, address: "Lyon, France", price: 450, status: true, user: john},
  {brand: "Lamborghini", category: "Sportive", model: "Urus AWD", year: 2021, address: "Paris, France", price: 850, status: true, user: john},
  {brand: "BMW", category: "SUV", model: "X5 xDrive40i", year: 2022, address: "Nice, France", price: 380, status: true, user: clara},
  {brand: "Tesla", category: "Électrique", model: "Model S Plaid", year: 2023, address: "Bordeaux, France", price: 480, status: true, user: clara}
]

cars_data.each do |car_attrs|
  Car.create!(car_attrs)
end

puts "✅ #{Car.count} voitures créées"

puts "\n📅 Création de réservations exemples..."

Booking.create!(
  car: Car.first,
  user: visitor1,
  checkin_date: Date.today + 3.days,
  checkout_date: Date.today + 7.days,
  status: :pending
)

Booking.create!(
  car: Car.second,
  user: visitor2,
  checkin_date: Date.today + 10.days,
  checkout_date: Date.today + 14.days,
  status: :accepted
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
