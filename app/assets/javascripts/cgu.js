function activation_bouton_submit(cgu_acceptees) {
  let bouton_submit = $('input[type="submit"]')
  if(cgu_acceptees) {
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

function cgu_activation_submit() {
  let cgu_acceptees = $("#compte_cgu_acceptees").is(':checked');

  activation_bouton_submit(cgu_acceptees);
  $('#compte_cgu_acceptees_input').on('change', () => {
    cgu_acceptees = !cgu_acceptees
    activation_bouton_submit(cgu_acceptees);
  });
}
