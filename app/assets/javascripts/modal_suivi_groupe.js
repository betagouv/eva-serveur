(function() {
  var MODAL_ID = "fr-modal-suivi-groupe";
  var FORM_ID = "suivi-groupe-form";

  function dsfrModal(modal) {
    if (!modal || !window.dsfr) return null;
    var instance = window.dsfr(modal);
    return instance && instance.modal ? instance.modal : null;
  }

  function discloseModal(modal) {
    var modalInstance = dsfrModal(modal);
    if (modalInstance) modalInstance.disclose();
  }

  /** Batch ActiveAdmin englobe la page : un second formulaire dans le HTML serait ignoré ; #suivi-groupe-form est créé ici sur body, champs reliés via attribut form. */
  function ensureSuiviGroupeFormDom(modal) {
    if (document.getElementById(FORM_ID)) return;

    var action = modal.dataset.suiviGroupeBatchAction;
    if (!action) return;

    var form = document.createElement("form");
    form.id = FORM_ID;
    form.method = "post";
    form.action = action;
    form.setAttribute("data-turbo", "false");
    form.style.display = "none";

    var meta = document.querySelector('meta[name="csrf-token"]');
    if (meta) {
      var tok = document.createElement("input");
      tok.type = "hidden";
      tok.name = "authenticity_token";
      tok.value = meta.getAttribute("content") || "";
      form.appendChild(tok);
    }

    document.body.appendChild(form);
  }

  function elementFromEventTarget(target) {
    if (!target) return null;
    if (target.nodeType === Node.TEXT_NODE) return target.parentElement;
    return target;
  }

  function findSuiviGroupeBatchLink(target) {
    var el = elementFromEventTarget(target);
    if (!el || !el.closest) return null;
    return el.closest("a.batch_action[data-action=\"renseigner_suivi_groupe\"]");
  }

  function handleSuiviGroupeClick(event) {
    var link = findSuiviGroupeBatchLink(event.target);
    if (!link) return;

    event.preventDefault();
    event.stopPropagation();
    event.stopImmediatePropagation();

    var modal = document.getElementById(MODAL_ID);
    if (!modal) return;

    var checkedBoxes = document.querySelectorAll(
      "input.batch-actions-resource-selection:checked"
    );

    if (checkedBoxes.length < 1) return;

    var ids = Array.from(checkedBoxes).map(function(cb) { return cb.value; });
    modal.dataset.ids = ids.join(",");

    discloseModal(modal);
  }

  function prepareHiddenInputs(modal) {
    var ids = (modal.dataset.ids || "").split(",").filter(function(id) {
      return id.length > 0;
    });
    var container = document.getElementById("hidden-ids-suivi-container");
    if (!container) return;

    container.innerHTML = "";

    ids.forEach(function(id) {
      var input = document.createElement("input");
      input.type = "hidden";
      input.name = "collection_selection[]";
      input.value = id;
      input.setAttribute("form", FORM_ID);
      container.appendChild(input);
    });
  }

  function init() {
    var modal = document.getElementById(MODAL_ID);
    if (!modal) return;

    ensureSuiviGroupeFormDom(modal);

    document.addEventListener("click", handleSuiviGroupeClick, true);

    var form = document.getElementById(FORM_ID);
    if (form) {
      form.addEventListener("submit", function() {
        prepareHiddenInputs(modal);
      });
    }
  }

  document.addEventListener("DOMContentLoaded", init);
})();
