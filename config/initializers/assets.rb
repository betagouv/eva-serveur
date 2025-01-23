Rails.application.config.assets.paths << Rails.root.join('node_modules/@gouvfr/dsfr/dist')
Rails.application.config.assets.precompile += %w[active_admin.css active_admin.js admin/pages/restitution_globale/restitution_globale_pdf.css]
