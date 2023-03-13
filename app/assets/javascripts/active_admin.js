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
//= require autocomplete_recherche_structure
//= require clipboard
//= require evaluation

//= require chartkick
//= require Chart.bundle
//= require i18n
//= require i18n/translations

jQuery.datetimepicker.setLocale('fr');

document.addEventListener('DOMContentLoaded', () => {
  $('#validation-comptes-en-attente').modal({
    show: true,
  });
  new ClipboardJS('.copier-coller');
  $('[data-toggle="tooltip"]').tooltip();
});

Chart.defaults.font.family = 'Work Sans';
Chart.defaults.font.size = 14;

