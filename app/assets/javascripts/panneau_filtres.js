(function() {
  function panneauxOuverts() {
    return document.querySelectorAll(".filtres__panneau.fr-collapse--expanded");
  }

  function ferme(panneau) {
    window.dsfr(panneau).collapse.conceal();
  }

  function init() {
    document.addEventListener("click", function(evenement) {
      panneauxOuverts().forEach(function(panneau) {
        if (!panneau.closest(".filtres__menu").contains(evenement.target)) ferme(panneau);
      });
    });

    document.addEventListener("keydown", function(evenement) {
      if (evenement.key !== "Escape") return;

      panneauxOuverts().forEach(function(panneau) {
        ferme(panneau);
        document.querySelector('[aria-controls="' + panneau.id + '"]').focus();
      });
    });
  }

  if (typeof module !== "undefined") { module.exports = { init }; }
  else { document.addEventListener("DOMContentLoaded", init); }
})();
