# Déploiement sur Render

## Prérequis
- Un compte Render (gratuit) : https://render.com
- Votre `RAILS_MASTER_KEY` (trouvé dans `config/master.key`)

## Étapes de déploiement

### 1. Pousser le code sur GitHub
```bash
git add .
git commit -m "Configure Render deployment"
git push origin main
```

### 2. Créer un nouveau service sur Render

1. Allez sur https://dashboard.render.com
2. Cliquez sur **"New +"** → **"Blueprint"**
3. Connectez votre dépôt GitHub **John-Dav9/LuxeDrive**
4. Render détectera automatiquement le fichier `render.yaml`

### 3. Configurer les variables d'environnement

Dans le dashboard Render, configurez ces variables **AVANT** le premier déploiement :

#### Variables obligatoires :
- `RAILS_MASTER_KEY` : Copiez le contenu de `config/master.key`
- `APP_HOST` : Votre URL Render (ex: `luxedrive.onrender.com`)

#### Variables SMTP (pour les emails) :
- `SMTP_ADDRESS` : Serveur SMTP (ex: `smtp.gmail.com`)
- `SMTP_DOMAIN` : Votre domaine
- `SMTP_USERNAME` : Votre email
- `SMTP_PASSWORD` : Mot de passe d'application

#### Variables de paiement (si nécessaire) :
- `STRIPE_PUBLISHABLE_KEY`
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `PAYPAL_CLIENT_ID`
- `PAYPAL_CLIENT_SECRET`

### 4. Lancer le déploiement

Render va automatiquement :
- Créer une base de données PostgreSQL
- Builder l'application avec Docker
- Exécuter les migrations
- Démarrer le serveur

### 5. Configuration post-déploiement

#### Webhooks Stripe
Si vous utilisez Stripe, configurez l'URL webhook :
```
https://votre-app.onrender.com/stripe/webhooks
```

#### Webhooks PayPal
Si vous utilisez PayPal, configurez l'URL webhook :
```
https://votre-app.onrender.com/paypal/webhooks
```

## Plan gratuit Render

Le plan gratuit inclut :
- 750 heures/mois de service web
- Base de données PostgreSQL (expire après 90 jours)
- Le service s'endort après 15 min d'inactivité
- Redémarre automatiquement à la première requête (peut prendre 30-60 secondes)

## Surveillance et logs

- **Logs** : Dashboard Render → Votre service → Logs
- **Shell** : Dashboard Render → Votre service → Shell (pour Rails console)
- **Métriques** : Dashboard Render → Votre service → Metrics

## Commandes utiles

### Accéder à la console Rails
Dans le shell Render :
```bash
bundle exec rails console
```

### Voir les migrations
```bash
bundle exec rails db:migrate:status
```

### Créer des données de test
```bash
bundle exec rails db:seed
```

## Dépannage

### L'application ne démarre pas
- Vérifiez que `RAILS_MASTER_KEY` est correct
- Consultez les logs dans le dashboard

### Erreur de base de données
- Vérifiez que les migrations ont bien tourné
- La variable `DATABASE_URL` doit être automatiquement définie

### Assets non chargés
- Vérifiez que `RAILS_SERVE_STATIC_FILES=true` est défini
- Relancez le build

## Migration depuis le développement

Si vous avez des données en développement que vous souhaitez migrer :
1. Exportez avec `pg_dump`
2. Importez dans Render via le shell ou pgAdmin

## Support

- Documentation Render : https://render.com/docs
- Documentation Rails : https://guides.rubyonrails.org
