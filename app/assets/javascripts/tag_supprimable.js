// Tag supprimable du DSFR : au clic, le JS du DSFR déplace le focus, retire le tag du DOM,
// puis émet dsfr.dismiss depuis le tag déjà détaché (l'événement ne remonte donc pas
// jusqu'au document). On repère le clic en phase de capture, sans l'arrêter, pour écouter
// dsfr.dismiss sur le tag lui-même et n'envoyer la suppression qu'une fois le tag retiré.
// En cas d'échec, le tag est remis à sa place avec un message d'erreur. Après un succès,
// data-affiche-apres-suppression peut désigner (par son id) un élément masqué à afficher,
// par exemple le formulaire d'ajout.

function tagSupprimableJetonCsrf() {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.content : '';
}

function tagSupprimableAfficheApresSuppression(tag) {
  const id = tag.dataset.afficheApresSuppression;
  const element = id && document.getElementById(id);
  if (!element) return;

  element.hidden = false;
  const premiereAction = element.querySelector('button, a[href], input:not([type="hidden"])');
  if (premiereAction) premiereAction.focus();
}

function tagSupprimableRestaure(tag, parent, suivant) {
  parent.insertBefore(tag, suivant);
  const erreur = document.createElement('p');
  erreur.className = 'fr-error-text tag-supprimable__erreur';
  erreur.setAttribute('role', 'alert');
  erreur.textContent = I18n.t('tag.erreur_suppression');
  tag.after(erreur);
  tag.focus();
}

function tagSupprimableEnvoieSuppression(tag, parent, suivant) {
  fetch(tag.dataset.urlSuppression, {
    method: 'PATCH',
    headers: { 'X-CSRF-Token': tagSupprimableJetonCsrf(), 'X-Requested-With': 'XMLHttpRequest' },
    credentials: 'same-origin'
  })
    .then((reponse) => {
      if (!reponse.ok || reponse.redirected) throw new Error(`Statut ${reponse.status}`);
      tagSupprimableAfficheApresSuppression(tag);
    })
    .catch(() => tagSupprimableRestaure(tag, parent, suivant));
}

document.addEventListener('click', (event) => {
  const tag = event.target.closest('button.fr-tag--dismiss[data-url-suppression]');
  if (!tag) return;

  const parent = tag.parentNode;
  const erreurPrecedente = parent.querySelector('.tag-supprimable__erreur');
  if (erreurPrecedente) erreurPrecedente.remove();
  const suivant = tag.nextSibling;

  tag.addEventListener('dsfr.dismiss', () => tagSupprimableEnvoieSuppression(tag, parent, suivant),
                       { once: true });
}, true);
