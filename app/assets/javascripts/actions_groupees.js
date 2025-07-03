
// Dans le cas de Firefox, les cases à cocher des actions groupées restent selectionnées après un
// rechargement simple de la page. Dans ce cas, on réactive le bouton.
document.addEventListener('DOMContentLoaded', () => {
  const bouton_actions_groupees = document.querySelector('.dropdown_menu_button');
  if(bouton_actions_groupees) {
    if (document.querySelector('input[type="checkbox"].batch-actions-resource-selection:checked')) {
      bouton_actions_groupees.classList.remove('disabled');
    }
  }
});
