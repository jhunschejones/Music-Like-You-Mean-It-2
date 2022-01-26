# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# ====== Local development data instructions ======
# 1. Import the production database dump for real site data
# 2. Run rake db:seed to reset users and create local admin
#
User.destroy_all
User.create(
  name: "Josh Jones",
  email: ENV["EMAIL_USERNAME"],
  password: ENV["DEV_PASSWORD"],
  password_confirmation: ENV["DEV_PASSWORD"],
  site_role: "admin"
)
