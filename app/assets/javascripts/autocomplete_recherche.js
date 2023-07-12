function estUnCodePostal(texte) {
  return texte.match(/^\d{5}$/);
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
    const recherche = $(".champ-recherche").val();
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

document.addEventListener('DOMContentLoaded', () => {
  $( ".champ-recherche" ).autocomplete({
    source: function (request, response) {
      $('#bouton-chercher').prop("disabled", true);
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
              const reponse = construitReponse(item, data.codePostal)
              return reponse;
            }))
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
      $('#bouton-chercher').prop("disabled", disabled);
    },
    autoFocus: false,
    minLength: 3,
    delay: 100
  });
});
