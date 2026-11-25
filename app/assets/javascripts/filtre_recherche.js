(function() {
  var LONGUEUR_MINIMALE = 2;

  function nomAffiche(proposition) {
    return proposition ? proposition.display_name : "";
  }

  function source(conteneur) {
    return function(saisie, afficheLesPropositions) {
      var url = new URL(conteneur.dataset.url, window.location.origin);
      url.searchParams.set("q[" + conteneur.dataset.predicat + "]", saisie);
      return fetch(url.pathname + url.search, { headers: { Accept: "application/json" } })
        .then(function(reponse) { return reponse.json(); })
        .then(afficheLesPropositions);
    };
  }

  function initialiseFiltre(conteneur) {
    var saisie = conteneur.querySelector("[data-filtre-recherche-saisie]");
    var champCache = conteneur.querySelector('input[type="hidden"]');

    initialiseAutocomplete({
      element: saisie,
      id: saisie.dataset.identifiant,
      name: "",
      defaultValue: conteneur.dataset.libelleValeur,
      minLength: LONGUEUR_MINIMALE,
      source: source(conteneur),
      templates: { inputValue: nomAffiche, suggestion: nomAffiche },
      onConfirm: function(proposition) {
        if (!proposition) return;

        champCache.value = proposition.id;
        if (conteneur.closest("[data-application-immediate]")) {
          conteneur.closest("form").requestSubmit();
        }
      }
    });

    saisie.addEventListener("input", function(evenement) {
      if (evenement.target.value.trim() === "") champCache.value = "";
    });

    var menu = conteneur.closest(".filtres__panneau");
    if (menu) {
      menu.addEventListener("dsfr.disclose", function() {
        document.getElementById(saisie.dataset.identifiant).focus();
      });
    }
  }

  function init() {
    document.querySelectorAll("[data-filtre-recherche]").forEach(initialiseFiltre);
  }

  if (typeof module !== "undefined") { module.exports = { init }; }
  else { document.addEventListener("DOMContentLoaded", init); }
})();
