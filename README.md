# 🚗 Luxe Drive

Luxe Drive est une plateforme de location de voitures de luxe, inspirée du modèle Airbnb. Elle permet aux utilisateurs de réserver des véhicules haut de gamme en toute simplicité, avec une interface fluide et responsive.

## 🛠️ Stack technique

- Ruby on Rails
- PostgreSQL
- Bootstrap
- Devise (authentification)
- Cloudinary (upload images)

## 🎯 Fonctionnalités

- Inscription / Connexion d’utilisateurs
- Mise en ligne de voitures avec photos et description
- Réservation de véhicules (dates, durée, prix)
- Interface responsive mobile / desktop

## 📷 Aperçus

> ![Page d'accueil de Luxe Drive](./asset/homepage.png)

## ▶️ Installation locale

```bash
git clone https://github.com/John-Dav9/rails-luxe-drive.git
cd rails-luxe-drive
bundle install
rails db:create db:migrate db:seed
rails server
