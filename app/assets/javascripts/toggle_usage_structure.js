document.addEventListener('DOMContentLoaded', function() {
  [ 'structure_locale', 'structure_administrative' ].forEach(function(modelName) {
    const usageRadios = document.querySelectorAll(`input[name="${modelName}[usage]"]`);
    const opcoField = document.getElementById('opco_field');
    const opcoFieldWrapper = opcoField?.closest('.input');
    const opcoLabel = document.getElementById('opco_label');
    const parentField = document.getElementById(`${modelName}_parent_id`);
    const parentFieldWrapper = parentField?.closest('.input');

    if (usageRadios.length > 0) {
      function toggleOpcoField() {
        const selectedUsage = document.querySelector(`input[name="${modelName}[usage]"]:checked`)?.value;
        const evaproSelected = selectedUsage === 'EVAPRO';

        if (evaproSelected && parentField) {
          parentField.value = '';
        }
        if (!evaproSelected && opcoField) {
          opcoField.value = '';
          opcoField.dispatchEvent(new Event('change', { bubbles: true }));
        }

        if (opcoFieldWrapper) {
          opcoFieldWrapper.style.display = evaproSelected ? '' : 'none';
        }
        if (opcoField) {
          opcoField.required = evaproSelected;
        }
        if (opcoFieldWrapper) {
          opcoFieldWrapper.classList.toggle("required", evaproSelected);
        }
        if (opcoLabel) {
          let requiredMarker = opcoLabel.querySelector("abbr[title='obligatoire']");
          if (evaproSelected && !requiredMarker) {
            requiredMarker = document.createElement("abbr");
            requiredMarker.setAttribute("title", "obligatoire");
            requiredMarker.textContent = "*";
            opcoLabel.appendChild(requiredMarker);
          } else if (!evaproSelected && requiredMarker) {
            requiredMarker.remove();
          }
        }
        if (parentFieldWrapper) {
          parentFieldWrapper.style.display = evaproSelected ? 'none' : '';
        }
      }

      toggleOpcoField();
      usageRadios.forEach(radio => radio.addEventListener('change', toggleOpcoField));
    }
  });
});

