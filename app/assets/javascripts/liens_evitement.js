window.addEventListener('load', () => {
  const skiplinks = document.createElement('div');
  skiplinks.className = 'fr-skiplinks';
  skiplinks.id = 'skiplink';
  skiplinks.innerHTML = `
    <nav class="fr-container" role="navigation" aria-label="Accès rapide">
      <ul class="fr-skiplinks__list">
        <li><a class="fr-link" href="#active_admin_content">Contenu</a></li>
        <li><a class="fr-link" href="#header">Menu</a></li>
        <li><a class="fr-link" href="#footer-principal">Pied de page</a></li>
      </ul>
    </nav>
  `;
  document.body.insertBefore(skiplinks, document.body.firstChild);
});
