(function() {
  function metAJour(conteneur) {
    var nombre = conteneur.querySelectorAll("input[data-fr-row-select]:checked").length;

    conteneur.querySelectorAll("[data-selection-compteur]").forEach(function(compteur) {
      compteur.textContent = I18n.t("components.tableau.lignes_selectionnees", { count: nombre });
    });

    conteneur.querySelectorAll("[data-selection-minimum]").forEach(function(bouton) {
      bouton.disabled = nombre < Number(bouton.dataset.selectionMinimum);
    });
  }

  function metAJourTout() {
    document.querySelectorAll("[data-selection-tableau]").forEach(metAJour);
  }

  // Écoute sur le document : les tableaux peuvent être remplacés par la recherche à la volée
  function init() {
    metAJourTout();
    document.addEventListener("resultats-actualises", metAJourTout);
    document.addEventListener("change", function(evenement) {
      if (!evenement.target.matches("input[data-fr-row-select]")) return;

      var conteneur = evenement.target.closest("[data-selection-tableau]");
      if (conteneur) metAJour(conteneur);
    });
  }

  if (typeof module !== "undefined") { module.exports = { init }; }
  else { document.addEventListener("DOMContentLoaded", init); }
})();
