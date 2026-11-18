// Au retour du suivi groupé, la liste ne montre que la sélection (EVA-1219) :
// on recoche les cases comme le ferait le conseiller, pour qu'ActiveAdmin
// active le menu « Actions groupées » et mette à jour la case d'en-tête.
// jQuery ready plutôt que DOMContentLoaded : ActiveAdmin branche ses écouteurs
// dans son propre ready, qui passerait sinon après nos clics.
$(() => {
  const conteneur = document.querySelector('[data-recoche-selection]');
  if (!conteneur) return;

  const ids = JSON.parse(conteneur.dataset.recocheSelection);
  document.querySelectorAll('input.batch-actions-resource-selection').forEach((caseACocher) => {
    if (ids.includes(caseACocher.value) && !caseACocher.checked) {
      caseACocher.click();
    }
  });
});
