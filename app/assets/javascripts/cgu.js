function activation_bouton_submit(peut_valider) {
  let bouton_submit = $('.valider-compte-bouton')
  if(peut_valider) {
    bouton_submit.removeClass('disabled');
    bouton_submit.removeAttr('disabled');
    bouton_submit.removeAttr('title');
  }
  else {
    bouton_submit.addClass('disabled');
    bouton_submit.attr('disabled', 'disabled');
    bouton_submit.attr('title', I18n.t('creation_compte.cgu_tool_tip'));
  }
}

function champ_rempli(selector) {
  return $(selector).val().trim() !== "";
}

function peut_valider_informations_compte() {
  const cgu_acceptees = $("#compte_cgu_acceptees").is(":checked");
  const nom_rempli = champ_rempli("#compte_nom");
  const prenom_rempli = champ_rempli("#compte_prenom");
  const email_rempli = champ_rempli("#compte_email");

  return cgu_acceptees && nom_rempli && prenom_rempli && email_rempli;
}

function cgu_activation_submit() {
  const rafraichir_bouton = () => {
    activation_bouton_submit(peut_valider_informations_compte());
  };

  rafraichir_bouton();
  $("#compte_cgu_acceptees_input").on("change", rafraichir_bouton);
  $("#compte_nom, #compte_prenom, #compte_email").on("input", rafraichir_bouton);
}
