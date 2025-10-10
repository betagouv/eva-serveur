document.addEventListener('DOMContentLoaded', function() {
  const usageRadios = document.querySelectorAll('input[name="structure_locale[usage]"]');
  const opcoField = document.getElementById('opco_field');
  const opcoFieldWrapper = opcoField?.closest('.input');
  
  if (usageRadios.length > 0 && opcoFieldWrapper) {
    function toggleOpcoField() {
      const selectedUsage = document.querySelector('input[name="structure_locale[usage]"]:checked')?.value;
      if (selectedUsage === 'Eva: entreprises') {
        opcoFieldWrapper.style.display = '';
      } else {
        opcoFieldWrapper.style.display = 'none';
      }
    }
    
    toggleOpcoField();
    
    usageRadios.forEach(radio => {
      radio.addEventListener('change', toggleOpcoField);
    });
  }
});

