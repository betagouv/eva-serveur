# EVA-376-les-resultats-sous-domaine-de-place-du-marche-sont-consultables-dans-lexport-pdf

## Remplacer wicked_pdf par puppeteer-ruby

- https://github.com/mileszs/wicked_pdf
- https://github.com/YusukeIwaki/puppeteer-ruby

Le problème est qu'aujourd'hui le DSFR utilise des FLEX et autres propriétés de CSS3 qui ne sont pas pris en charge par wkhtmltopdf (dépendance de wicked_pdf).
Par conséquent, il est nécessaire de migrer vers puppeteer-ruby, qui utilise un moteur de rendu basé sur Chromium et prend en charge les dernières fonctionnalités CSS.

Standard utiliser Puppeteer : https://captive.notion.site/Exporter-un-PDF-avec-Puppeteer-1b2707bff8eb80de9463c211323daa3c?pvs=4

## Étapes

- Installer Puppeteer
- Rendre la page à l'aide de Puppeteer
- Utiliser le Feature Review de Scalingo pour vérifier que le rendu PDF fonctionne
- Ajuster si il y a des propriétés qui ne sont pas rendus
- Supprimer le code mort
