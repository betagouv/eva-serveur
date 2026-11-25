(function() {
  var DELAI = 300;
  var minuterie = null;
  var requeteEnCours = null;

  function urlDuFormulaire(formulaire) {
    var parametres = new URLSearchParams(new FormData(formulaire));
    return formulaire.action + "?" + parametres.toString();
  }

  function remplaceLesZones(html) {
    var reponse = new DOMParser().parseFromString(html, "text/html");
    document.querySelectorAll("[data-actualise-a-la-volee]").forEach(function(zone) {
      var nouvelleZone = reponse.getElementById(zone.id);
      if (nouvelleZone) zone.replaceWith(nouvelleZone);
    });
  }

  function actualise(formulaire) {
    if (requeteEnCours) requeteEnCours.abort();
    requeteEnCours = new AbortController();

    var url = urlDuFormulaire(formulaire);
    return fetch(url, { signal: requeteEnCours.signal, headers: { Accept: "text/html" } })
      .then(function(reponse) { return reponse.text(); })
      .then(function(html) {
        remplaceLesZones(html);
        window.history.replaceState(null, "", url);
        document.dispatchEvent(new CustomEvent("resultats-actualises"));
      })
      .catch(function(erreur) {
        if (erreur.name !== "AbortError") throw erreur;
      });
  }

  function init() {
    document.querySelectorAll("[data-recherche-a-la-volee]").forEach(function(champ) {
      champ.addEventListener("input", function() {
        clearTimeout(minuterie);
        minuterie = setTimeout(function() { actualise(champ.form); }, DELAI);
      });
    });
  }

  if (typeof module !== "undefined") { module.exports = { init: init, DELAI: DELAI }; }
  else { document.addEventListener("DOMContentLoaded", init); }
})();
