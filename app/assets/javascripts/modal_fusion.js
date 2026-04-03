(function() {
  var MODAL_ID = "fr-modal-fusionner";
  var FORM_ID = "fusion-form";
  var OPENED_CLASS = "fr-modal--opened";

  /** Batch ActiveAdmin englobe la page : un second formulaire dans le HTML serait ignoré ; #fusion-form est créé ici sur body, champs reliés via attribut form. */
  function ensureFusionFormDom(modal) {
    if (document.getElementById(FORM_ID)) return;

    var action = modal.dataset.fusionBatchAction;
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

  function findFusionBatchLink(target) {
    var el = elementFromEventTarget(target);
    if (!el || !el.closest) return null;
    return el.closest("a.batch_action[data-action=\"fusionner\"]");
  }

  function openFusionModal(modal) {
    if (!modal) return;

    if (modal.parentNode !== document.body) {
      document.body.appendChild(modal);
    }

    // Comme invitation_modal / modal_verification : pas showModal() (top layer native non fermée par le DSFR).
    modal.classList.add(OPENED_CLASS);
    modal.setAttribute("aria-hidden", "false");
    if (modal.tagName === "DIALOG" && !modal.hasAttribute("open")) {
      modal.setAttribute("open", "");
    }
  }

  function closeFusionModal(modal) {
    if (!modal) return;
    modal.classList.remove(OPENED_CLASS);
    modal.setAttribute("aria-hidden", "true");
    if (modal.tagName === "DIALOG") {
      if (typeof modal.close === "function") {
        try {
          modal.close();
        } catch (e) {
          modal.removeAttribute("open");
        }
      } else {
        modal.removeAttribute("open");
      }
    }
  }

  function bindFusionCloseHandlers(modal) {
    if (!modal || modal.dataset.fusionModalBound === "true") return;
    modal.dataset.fusionModalBound = "true";

    modal.addEventListener("click", function(event) {
      if (event.target === modal) {
        event.preventDefault();
        closeFusionModal(modal);
      }
    });

    var selectors =
      '[aria-controls="' + modal.id + '"], .fr-link--close, .fr-btn--close';
    modal.querySelectorAll(selectors).forEach(function(trigger) {
      trigger.addEventListener("click", function(event) {
        if (trigger.type === "submit") return;
        event.preventDefault();
        closeFusionModal(modal);
      });
    });
  }

  function bindFusionEscapeHandler() {
    if (document.body.dataset.fusionModalEscapeBound === "true") return;
    document.body.dataset.fusionModalEscapeBound = "true";

    document.addEventListener("keydown", function(event) {
      if (event.key !== "Escape") return;
      var modal = document.getElementById(MODAL_ID);
      if (modal && modal.classList.contains(OPENED_CLASS)) {
        closeFusionModal(modal);
      }
    });
  }

  function handleFusionClick(event) {
    var link = findFusionBatchLink(event.target);
    if (!link) return;

    event.preventDefault();
    event.stopPropagation();
    event.stopImmediatePropagation();

    var modal = document.getElementById(MODAL_ID);
    if (!modal) return;

    var checkedBoxes = document.querySelectorAll(
      "input.batch-actions-resource-selection:checked"
    );

    if (checkedBoxes.length < 2) {
      window.alert("Sélectionnez au moins deux bénéficiaires pour les fusionner.");
      return;
    }

    var beneficiaires = extractBeneficiairesData(checkedBoxes);
    var sortedBeneficiaires = sortBeneficiairesByDate(beneficiaires);

    updateModalContent(modal, sortedBeneficiaires);
    openFusionModal(modal);
  }

  function extractBeneficiairesData(checkedBoxes) {
    return Array.from(checkedBoxes).map(function(checkbox) {
      var row = checkbox.closest("tr");
      return {
        id: checkbox.value,
        nom: extractNomFromRow(row),
        dateISO8601: extractDateFromRow(row)
      };
    });
  }

  function extractNomFromRow(row) {
    if (!row) return "Inconnu";
    var cell = row.querySelector("td:nth-child(2)");
    return (cell && cell.textContent.trim()) || "Inconnu";
  }

  function extractDateFromRow(row) {
    if (!row) return "";
    var dateCell = row.querySelector(".col-created_at span[data-created-at]");
    return (dateCell && dateCell.dataset.createdAt) || "";
  }

  function sortBeneficiairesByDate(beneficiaires) {
    return beneficiaires.slice().sort(function(a, b) {
      if (a.dateISO8601 < b.dateISO8601) return -1;
      if (a.dateISO8601 > b.dateISO8601) return 1;
      return 0;
    });
  }

  function updateModalContent(modal, beneficiaires) {
    var listeElements = document.getElementById("liste-elements-a-fusionner");
    listeElements.innerHTML = "";
    beneficiaires.forEach(function(b) {
      var li = document.createElement("li");
      li.textContent = b.nom;
      listeElements.appendChild(li);
    });

    var rattacheElement = document.getElementById("beneficiaire-rattache");
    rattacheElement.textContent = beneficiaires[0].nom;

    var rattacheAlertElement = document.getElementById("beneficiaire-rattache-alert");
    if (rattacheAlertElement) {
      rattacheAlertElement.textContent = beneficiaires[0].nom;
    }

    modal.dataset.ids = beneficiaires.map(function(b) {
      return b.id;
    }).join(",");
  }

  function prepareHiddenInputs(modal) {
    var ids = (modal.dataset.ids || "").split(",").filter(function(id) {
      return id.length > 0;
    });
    var container = document.getElementById("hidden-ids-container");
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

    document.body.appendChild(modal);
    ensureFusionFormDom(modal);
    modal.setAttribute("aria-hidden", "true");
    bindFusionCloseHandlers(modal);
    bindFusionEscapeHandler();

    document.addEventListener("click", handleFusionClick, true);

    var form = document.getElementById(FORM_ID);
    if (form) {
      form.addEventListener("submit", function() {
        prepareHiddenInputs(modal);
      });
    }
  }

  document.addEventListener("DOMContentLoaded", init);
})();
