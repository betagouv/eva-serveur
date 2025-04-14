function convertir_champ(input, label) {
  input.type = 'date';
  input.classList.remove('datepicker', 'hasDatepicker');
  input.removeAttribute('autocomplete');

  const labelElement = document.createElement('label');
  labelElement.setAttribute('for', input.id);
  labelElement.textContent = label;
  input.parentNode.insertBefore(labelElement, input);
}

function utilise_date_picker_du_dsfr(filtre) {
  filtre.querySelectorAll('label').forEach((label) => label.remove());
  const champs = filtre.querySelectorAll('input');
  convertir_champ(champs[0], I18n.t('admin.date_depuis'));
  convertir_champ(champs[1], I18n.t('admin.date_jusqua'));
}

document.addEventListener('DOMContentLoaded', () => {
  utilise_date_picker_du_dsfr(document.getElementById('q_created_at_input'));
});

