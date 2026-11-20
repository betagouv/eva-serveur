(function() {
  var MODAL_ID = "fr-modal-fusionner";

  function beneficiairesCoches(formulaire) {
    var cases = formulaire.querySelectorAll('input[name="beneficiaire_ids[]"]:checked');
    return Array.from(cases).map(function(caseACocher) {
      var ligne = caseACocher.closest("tr");
      return {
        nom: ligne.querySelector("[data-nom]").textContent.trim(),
        creeLe: ligne.querySelector("[data-created-at]").dataset.createdAt
      };
    });
  }

  function parAnciennete(a, b) {
    if (a.creeLe < b.creeLe) return -1;
    if (a.creeLe > b.creeLe) return 1;
    return 0;
  }

  function afficheRecapitulatif(beneficiaires) {
    var liste = document.getElementById("liste-elements-a-fusionner");
    liste.replaceChildren.apply(liste, beneficiaires.map(function(beneficiaire) {
      var element = document.createElement("li");
      element.textContent = beneficiaire.nom;
      return element;
    }));

    var rattache = beneficiaires.length > 0 ? beneficiaires[0].nom : "";
    document.getElementById("beneficiaire-rattache").textContent = rattache;
    document.getElementById("beneficiaire-rattache-alert").textContent = rattache;
  }

  function init() {
    var modal = document.getElementById(MODAL_ID);
    if (!modal) return;

    modal.addEventListener("dsfr.disclose", function() {
      var formulaire = document.getElementById(modal.dataset.formulaireSelection);
      afficheRecapitulatif(beneficiairesCoches(formulaire).sort(parAnciennete));
    });
  }

  if (typeof module !== "undefined") { module.exports = { init }; }
  else { document.addEventListener("DOMContentLoaded", init); }
})();
