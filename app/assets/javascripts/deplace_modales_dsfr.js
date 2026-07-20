(function() {
  /** Les modales peuvent être rendues dans des conteneurs stylés (ex :
   * .sidebar_section d'ActiveAdmin), dont le CSS s'applique à leur contenu
   * même une fois ouvertes : position: fixed ne change que l'affichage, pas
   * la place de l'élément dans l'arbre DOM, donc le cascade CSS du conteneur
   * d'origine continue de s'appliquer. On déplace chaque modale sur body pour
   * l'en affranchir.
   */
  function moveModalsToBody() {
    document.querySelectorAll(".fr-modal:not(.fr-header__menu)").forEach(function(modal) {
      if (modal.parentElement !== document.body) {
        document.body.appendChild(modal);
      }
    });
  }

  document.addEventListener("DOMContentLoaded", moveModalsToBody);
})();
