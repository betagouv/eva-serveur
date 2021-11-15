//= require active_admin/base
//= require activeadmin_addons/all
//= require vendor/select2_locale_fr
//= require vendor/datepicker-fr
//= require activeadmin_reorderable
//= require jquery3
//= require popper
//= require bootstrap
//= require faq
//= require aide
//= require clipboard

jQuery.datetimepicker.setLocale('fr');

document.addEventListener('DOMContentLoaded', () => {
  $('#validation-comptes-en-attente').modal({
    show: true,
    backdrop: false
  });
  new ClipboardJS('.copier-coller');
});

