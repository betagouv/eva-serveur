# Pdf::Navigateur mémorise un navigateur Puppeteer dans une variable de classe
# pour le réutiliser entre les générations de PDF. En développement, le
# rechargement du code (Zeitwerk) réinitialise cette variable sans jamais
# fermer le processus Chrome sous-jacent, qui reste alors orphelin.
# On le ferme explicitement juste avant que la classe ne soit déchargée.
Rails.autoloaders.main.on_unload("Pdf::Navigateur") do |klass, _abspath|
  klass.reset!
end
