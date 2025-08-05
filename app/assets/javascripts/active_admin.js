//= require active_admin/base
//= require activeadmin_addons/all
//= require actions_groupees
//= require liens_evitement
//= require vendor/select2_locale_fr
//= require accessible-autocomplete.min
//= require activeadmin_reorderable
//= require jquery3
//= require popper
//= require bootstrap
//= require aide
//= require autocomplete_recherche
//= require filtres_dates
//= require form_toggle_submit
//= require menu_mobile
//= require bouton_menu_actions
//= require cgu
//= require clipboard
//= require evaluation
//= require simple_mde
//= require modal_verification
//= require comparer_evaluations_positionnement

//= require chartkick
//= require Chart.bundle
//= require i18n
//= require i18n/translations

jQuery.datetimepicker.setLocale('fr');
I18n.locale = 'fr';

document.addEventListener('DOMContentLoaded', () => {
  $('#validation-comptes-en-attente').modal();
  $('.modal--static').modal({
    backdrop: 'static',
    keyboard: false
  });
  new ClipboardJS('.copier-coller');
  $('[data-toggle="tooltip"]').tooltip();
});

Chart.defaults.font.family = 'Work Sans';
Chart.defaults.font.size = 14;
