/**
 * Accordéon DSFR (critères numératie) : le bundle DSFR peut ne pas relier le bouton
 * au panneau (ordre de scripts, ou calque header qui capte les clics avant le bouton).
 * On force l’ouverture/fermeture sur pointerdown en capture pour rester prioritaire.
 */
(function() {
  var COLLAPSE_EXPANDED = "fr-collapse--expanded";

  function findToggleButton(target) {
    if (!target || !target.closest) return null;
    return target.closest(
      "#numeratie .fr-accordion__btn, .sous-competence__critere-accordion .fr-accordion__btn"
    );
  }

  function toggleAccordion(btn) {
    var panelId = btn.getAttribute("aria-controls");
    if (!panelId) return;
    var panel = document.getElementById(panelId);
    if (!panel || panel.classList.contains("fr-collapse") === false) return;

    var willOpen = btn.getAttribute("aria-expanded") !== "true";
    btn.setAttribute("aria-expanded", willOpen ? "true" : "false");
    panel.classList.toggle(COLLAPSE_EXPANDED, willOpen);
    if (willOpen) {
      panel.removeAttribute("hidden");
    } else {
      panel.setAttribute("hidden", "hidden");
    }
  }

  function handleActivation(event, btn) {
    event.preventDefault();
    event.stopImmediatePropagation();
    toggleAccordion(btn);
  }

  document.addEventListener(
    "pointerdown",
    function(event) {
      var btn = findToggleButton(event.target);
      if (!btn) return;
      handleActivation(event, btn);
    },
    true
  );

  document.addEventListener(
    "keydown",
    function(event) {
      if (event.key !== "Enter" && event.key !== " ") return;
      var btn = findToggleButton(event.target);
      if (!btn || event.target !== btn) return;
      handleActivation(event, btn);
    },
    true
  );
})();
