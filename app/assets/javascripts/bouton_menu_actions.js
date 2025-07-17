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

            const rect_bouton = bouton_menu.getBoundingClientRect();
            let posX = rect_bouton.left;
            let posY = rect_bouton.bottom + 4;

            const largeur_fenetre = window.innerWidth;
            const largeur_menu = menu.getBoundingClientRect().width;
            if (posX + largeur_menu > largeur_fenetre) {
                posX = largeur_fenetre - largeur_menu;
            }

            menu.style.left = posX + 'px';
            menu.style.top = posY + 'px';
            menu.classList.toggle('montrer');
        });
        bouton_menu.parentElement.addEventListener("mouseleave", () => {
            menu.classList.remove('montrer');
        });
    });
});
