//= require active_admin/base
//= require activeadmin_addons/all
//= require select2_locale_fr
//= require vendor/datepicker-fr
//= require activeadmin_reorderable
//= require faq
//= require aide
//= require clipboard

jQuery.datetimepicker.setLocale('fr');

document.addEventListener('DOMContentLoaded', () => {
  new ClipboardJS('.copier-coller');
});
