document.addEventListener('DOMContentLoaded', function() {
  const usageRadios = document.querySelectorAll(`input[name="structure_locale[usage]"]`);
  const parentField = document.getElementById(`structure_locale_parent_id`);
  const parentFieldWrapper = parentField?.closest('.input');

  if (usageRadios.length > 0) {
    function toggleOpcoField() {
      const selectedUsage = document.querySelector(`input[name="structure_locale[usage]"]:checked`)?.value;
      const evaproSelected = selectedUsage === 'EVAPRO';

      if (evaproSelected && parentField) {
        parentField.value = '';
      }
      
      if (parentFieldWrapper) {
        parentFieldWrapper.style.display = evaproSelected ? 'none' : '';
      }
    }

    toggleOpcoField();
    usageRadios.forEach(radio => radio.addEventListener('change', toggleOpcoField));
  }
});
