//= require active_admin/base
//= require activeadmin_addons/all
//= require vendor/select2_locale_fr
//= require vendor/datepicker-fr
//= require activeadmin_reorderable
//= require jquery3
//= require jquery-ui
//= require popper
//= require bootstrap
//= require faq
//= require aide
//= require clipboard

//= require chartkick
//= require Chart.bundle

jQuery.datetimepicker.setLocale('fr');

document.addEventListener('DOMContentLoaded', () => {
  $('#validation-comptes-en-attente').modal({
    show: true,
  });
  new ClipboardJS('.copier-coller');

  $( ".champ-recherche" ).autocomplete({
    source: function (request, response) {
      $.ajax({
        url: "https://api-adresse.data.gouv.fr/search/",
        data: { q: request.term },
        dataType: "json",
        success: function (data) {
          response($.map(data.features, function (item) {
            return { label: item.properties.label, value: item.properties.label };
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
      const disabled = ui.item.value == '';
      $('#bouton-chercher').prop("disabled", disabled);
    },
    autoFocus: false,
    minLength: 2,
    delay: 100
  });
});

Chart.defaults.font.family = 'Work Sans';
Chart.defaults.font.size = 14;
