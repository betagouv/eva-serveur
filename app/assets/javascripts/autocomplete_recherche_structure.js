document.addEventListener('DOMContentLoaded', () => {
  $( ".champ-recherche" ).autocomplete({
    source: function (request, response) {
      $('#code_postal').val('');
      $.ajax({
        url: "https://api-adresse.data.gouv.fr/search/",
        data: { q: request.term, limit: 6, type: 'municipality', autocomplete: 1 },
        dataType: "json",
        success: function (data) {
          response($.map(data.features, function (item) {
            const label = `${item.properties.city} (${item.properties.postcode})`;
            return { label: label, value: label, code_postal: item.properties.postcode };
          }))
        },
        error: function () {
          response([]);
        }
      });
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
    minLength: 2,
    delay: 100
  });
});
