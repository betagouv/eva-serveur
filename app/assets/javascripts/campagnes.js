$(document).ready(function(){
  $('.input-choix-option-parcours_type').click(function(){
    $('#zone-de-personnalisation').show();
    $('html, body').animate({
      scrollTop: $("#zone-de-personnalisation").offset().top
    }, 300);
  });
});
