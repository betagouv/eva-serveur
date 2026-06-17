//= require active_admin/base
//= require image_file_input_clear
//= require activeadmin_addons/all
//= require actions_groupees
//= require liens_evitement
//= require vendor/select2_locale_fr
//= require accessible-autocomplete.min
//= require autocomplete_recherche
//= require activeadmin_reorderable
//= require jquery3
//= require popper
//= require bootstrap
//= require aide
//= require filtres_dates
//= require form_toggle_submit
//= require toggle_usage_structure
//= require bouton_menu_actions
//= require cgu
//= require siret_input
//= require code_postal_input
//= require numero_telephone_input
//= require recherche_structure
//= require vendor/clipboard.min
//= require evaluation
//= require simple_mde
//= require modal_verification
//= require comparer_evaluations_positionnement
//= require modal_fusion
//= require structure_confirmation
//= require nouveau_compte
//= require reset_password

//= require chartkick
//= require Chart.bundle
//= require i18n
//= require i18n/translations

jQuery.datetimepicker.setLocale('fr');
I18n.locale = 'fr';

document.addEventListener('DOMContentLoaded', () => {
  new ClipboardJS('.copier-coller');
  $('[data-toggle="tooltip"]').tooltip();
});

Chart.defaults.font.family = 'Marianne';
Chart.defaults.font.size = 14;
