function initialize() {
  const inputType = document.getElementById("question_qcm_type");
  inputType && inputType.value === 'QuestionQcm' ? $('.choix').show() : $('.choix').hide();
}

function displayInputChoixOnCreate() {
  $('#question_type_input').on('change', function(event) {
    event.target.value === 'QuestionQcm' ? $('.choix').show() : $('.choix').hide();
  });
}

function displayInputChoixOnEdit() {
  $('#question_saisie_type_input').on('change', function(event) {
    event.target.value === 'QuestionQcm' ? $('.choix').show() : $('.choix').hide();
  });
  $('#question_qcm_type_input').on('change', function(event) {
    event.target.value === 'QuestionQcm' ? $('.choix').show() : $('.choix').hide();
  });
}


document.addEventListener('DOMContentLoaded', () => {
  const form = document.querySelector(".form-question");

  if(form) {
    initialize();
    displayInputChoixOnCreate();
    displayInputChoixOnEdit();
  }
});
