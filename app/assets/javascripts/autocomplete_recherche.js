function estUnCodePostal(texte) {
  return texte.match(/^\d{5}$/);
}

function capitalise(s) {
    return s[0].toUpperCase() + s.slice(1);
}

function construitReponse(item, codePostalSaisi) {
  const ville = item.nom;
  let codePostal = '';
  if (codePostalSaisi && item.codesPostaux.length > 1) {
    codePostal = codePostalSaisi
  } else {
    codePostal = item.codesPostaux[0];
  }
  const label = `${ville} (${codePostal})`;
  return { label: label, value: label, code_postal: codePostal };
}

function ajouteReponseAucunResultat(event, ui) {
  if (!ui.content.length) {
    const recherche = $(event.target).val();
    const reponseAucunResultat = {
      value: '',
      label: `Aucun résultat ne correspond à la recherche "${recherche}"`
    };
    ui.content.push(reponseAucunResultat);
  }
}

function afficheRecherche(boutonAjout, formulaireRecherche) {
  boutonAjout.click(function () {
    boutonAjout.hide()
    formulaireRecherche.show()
  });
}

function autocompleteRechercheStructure() {
  return {
    source: function (request, response) {
      $('#bouton-chercher')
        .prop("disabled", true)
        .addClass("disabled");
      if (!request.term.match(/^\d{1,4}$/)) {
        let data = { limit: 6, type: 'commune-actuelle,arrondissement-municipal' };
        if (estUnCodePostal(request.term)) {
          data.codePostal = request.term
        } else {
          data.nom = request.term;
          data.boost = 'population';
        }
        $.ajax({
          url: "https://geo.api.gouv.fr/communes",
          data: data,
          dataType: "json",
          success: function (datas) {
            response($.map(datas, function (item) {
              return construitReponse(item, data.codePostal)
            }));
          },
          error: function () {
            response([]);
          }
        });
      }
    },
    response: ajouteReponseAucunResultat,
    select: function( event, ui ) {
      $('#code_postal').val(ui.item.code_postal);

      const disabled = ui.item.value == '';
      $('#bouton-chercher')
        .prop("disabled", disabled)
        .toggleClass('disabled', disabled);
    },
    autoFocus: false,
    minLength: 3,
    delay: 100
  };
}

document.addEventListener('DOMContentLoaded', () => {
  $(".autocomplete-nom-structure input").autocomplete({
    source: function (request, response) {
      const nom = encodeURI(request.term);
      let code_postal = $('.autocomplete-code-postal input').val().trim();
      if(code_postal.length != 0) {
        code_postal = `&code_postal=${encodeURI(code_postal)}`
      }
      $.ajax({
        url: `https://recherche-entreprises.api.gouv.fr/search?q=${nom}${code_postal}&per_page=6`,
        success: function (datas) {
          let reponses = [];
          for(const item of datas.results) {
            for(const etablissement of item.matching_etablissements) {
              const value = capitalise(item.nom_complet.toLowerCase());
              const label = `${value} - ${etablissement.adresse}`;
              reponses.push({
                label: label,
                value: value,
                siret: item.siege.siret,
                code_postal: etablissement.code_postal
              });
            }
          }
          response(reponses);
        },
        error: function () {
          response([]);
        }
      });
    },
    response: ajouteReponseAucunResultat,
    select: function( event, ui ) {
      $('.autocomplete-siret input').val(ui.item.siret)
      $('.autocomplete-code-postal input').val(ui.item.code_postal)
    },
    autoFocus: false,
    minLength: 3,
    delay: 150
  });
});
