document.addEventListener("DOMContentLoaded", function() {
  setupResetPasswordEmailForms();
});

function setupResetPasswordEmailForms() {
  ["reset-password-request-submit", "reset-password-invalid-submit"].forEach(function(buttonId) {
    var submitButton = document.getElementById(buttonId);
    var emailInput = document.getElementById("compte_email");

    if (!submitButton || !emailInput) {
      return;
    }

    function emailRempli() {
      return emailInput.value.trim().length > 0;
    }

    function updateSubmitState() {
      var enable = emailRempli();

      submitButton.disabled = !enable;
      submitButton.classList.toggle("disabled", !enable);
    }

    emailInput.addEventListener("input", updateSubmitState);
    emailInput.addEventListener("change", updateSubmitState);

    if (submitButton.dataset.initialDisabled) {
      submitButton.disabled = true;
    }

    updateSubmitState();
  });
}

