document.addEventListener("DOMContentLoaded", function() {
  setupResetPasswordEditForm();
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

function setupResetPasswordEditForm() {
  var submitButton = document.getElementById("reset-password-submit");
  var passwordInput = document.getElementById("compte_password");
  var passwordConfirmationInput = document.getElementById("compte_password_confirmation");

  if (!submitButton || !passwordInput || !passwordConfirmationInput) {
    return;
  }

  function updateSubmitState() {
    var passwordPresent = passwordInput.value.trim().length > 0;
    var confirmationPresent = passwordConfirmationInput.value.trim().length > 0;
    var passwordsMatch = passwordInput.value === passwordConfirmationInput.value;
    var enableButton = passwordPresent && confirmationPresent && passwordsMatch;

    submitButton.disabled = !enableButton;
    submitButton.classList.toggle("disabled", !enableButton);
  }

  passwordInput.addEventListener("input", updateSubmitState);
  passwordConfirmationInput.addEventListener("input", updateSubmitState);

  if (submitButton.dataset.initialDisabled) {
    submitButton.disabled = true;
  }

  updateSubmitState();
}
