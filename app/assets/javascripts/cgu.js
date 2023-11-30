function activation_submit(cgu_acceptees) {
  let bouton_submit = $('input[type="submit"]')
  if(cgu_acceptees) {
    bouton_submit.removeClass('disabled');
    bouton_submit.removeAttr('disabled');
    bouton_submit.removeAttr('title');
  }
  else {
    bouton_submit.addClass('disabled');
    bouton_submit.attr('disabled', 'disabled');
    bouton_submit.attr('title', 'Veuillez accepter les CGU');
  }
}

function cgu_activation_submit() {
  let cgu_acceptees = $("#compte_cgu_acceptees").is(':checked');

  activation_submit(cgu_acceptees);
  $('#compte_cgu_acceptees_input').on('change', () => {
    cgu_acceptees = !cgu_acceptees
    activation_submit(cgu_acceptees);
  });
}
