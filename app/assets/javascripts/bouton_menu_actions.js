(function() {
  function trouve_le_menu(bouton) {
    return bouton.parentElement.querySelector('.table_actions');
  }

  function deplace_menu(bouton_menu, menu) {
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
  }

  function equipe(colonne_action) {
    const bouton_menu = document.createElement('button');
    bouton_menu.className = 'bouton bouton-menu';
    bouton_menu.tabIndex = -1;
    bouton_menu.setAttribute('aria-label', I18n.t('components.bouton_menu_actions.label'));
    colonne_action.insertBefore(bouton_menu, colonne_action.firstChild);

    const menu = trouve_le_menu(bouton_menu);
    bouton_menu.addEventListener('click', (event) => {
      event.preventDefault();
      deplace_menu(bouton_menu, menu);
      menu.classList.toggle('montrer');
    });
    menu.querySelector('a').addEventListener('focus', () => {
      deplace_menu(bouton_menu, menu);
    });
    colonne_action.addEventListener('mouseleave', () => {
      menu.classList.remove('montrer');
    });
  }

  function equipeLesLignes() {
    document.querySelectorAll('td.col-actions').forEach((colonne_action) => {
      if (!colonne_action.querySelector(':scope > .bouton-menu')) equipe(colonne_action);
    });
  }

  // Les lignes remplacées par la recherche à la volée sont équipées à leur tour
  function init() {
    equipeLesLignes();
    document.addEventListener('resultats-actualises', equipeLesLignes);
  }

  if (typeof module !== 'undefined') { module.exports = { init }; }
  else { document.addEventListener('DOMContentLoaded', init); }
})();
