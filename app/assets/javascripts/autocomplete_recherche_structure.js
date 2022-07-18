function estUnCodePostal(texte) {
  return texte.match(/^\d{5}$/);
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
          success: function (data) {
            response($.map(data, function (item) {
              const ville = item.nom;
              const codePostal = item.codesPostaux[0];
              const label = `${ville} (${codePostal})`;
              return { label: label, value: label, code_postal: codePostal };
            }))
          },
          error: function () {
            response([]);
          }
        });
      }
    },
    response: function(event, ui) {
      if (!ui.content.length) {
        const recherche = $(".champ-recherche").val();
        const noResult = {
          value: '',
          label: `Aucun résultat ne correspond à la recherche "${recherche}"`
        };
        ui.content.push(noResult);
      }
    },
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
