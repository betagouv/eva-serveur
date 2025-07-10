function trouve_le_menu(bouton) {
  let parent_commun = bouton.closest('tr, .contenu');
  return parent_commun.querySelector('.table_actions')
}

document.addEventListener('DOMContentLoaded', () => {
    const celules = document.querySelectorAll('td.col-actions');

    for (const colonne_action of celules) {
        const bouton = document.createElement('button');
        bouton.className = 'bouton bouton-menu';
        bouton.tabIndex = -1;
        bouton.setAttribute('aria-label', I18n.t('components.bouton_menu_actions.label'));

        colonne_action.insertBefore(bouton, colonne_action.firstChild);
    }
    let boutons = document.getElementsByClassName('bouton-menu')
    Array.from(boutons).forEach((bouton_menu) => {
        let menu = trouve_le_menu(bouton_menu);
        bouton_menu.addEventListener('click', (event) => {
            event.preventDefault();
            menu.classList.toggle('montrer');
        });
        bouton_menu.parentElement.addEventListener("mouseleave", () => {
            menu.classList.remove('montrer');
        });
    });
});
