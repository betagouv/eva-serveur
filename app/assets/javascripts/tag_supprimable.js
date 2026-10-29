// Le DSFR retire du DOM le bouton d'un tag supprimable dès le clic, ce qui annule
// l'envoi du formulaire button_to. On arrête le clic en phase de capture pour que
// le gestionnaire du DSFR ne s'exécute pas et que le formulaire parte normalement.
document.addEventListener('click', (event) => {
  if (event.target.closest('form.button_to button.fr-tag--dismiss')) {
    event.stopPropagation();
  }
}, true);
