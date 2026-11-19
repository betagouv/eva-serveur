const DUREE_AFFICHAGE_INFOBULLE_COPIE = 2000;

function afficheInfobulleCopie(bouton) {
  const infobulle = document.getElementById(bouton.getAttribute('aria-describedby'));
  if (!infobulle || !window.dsfr) return;

  // hidden empêche l'infobulle de s'afficher au survol avant la copie
  infobulle.hidden = false;
  window.dsfr(infobulle).tooltip.show();
  clearTimeout(infobulle.minuteur);
  infobulle.minuteur = setTimeout(() => {
    window.dsfr(infobulle).tooltip.hide();
    infobulle.hidden = true;
  }, DUREE_AFFICHAGE_INFOBULLE_COPIE);
}

document.addEventListener('DOMContentLoaded', () => {
  new ClipboardJS('.copier-coller').on('success', (evenement) => afficheInfobulleCopie(evenement.trigger));
});

if (typeof module !== 'undefined') module.exports = { afficheInfobulleCopie };
