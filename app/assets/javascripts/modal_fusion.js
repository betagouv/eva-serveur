(function() {
  var MODAL_ID = "fr-modal-fusionner";
  var OPENED_CLASS = "fr-modal--opened";

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

    // Même stratégie que modal_verification_ouverture_evapro / invitation_modal :
    // ne pas dépendre de window.dsfr (instance parfois absente ou non enregistrée).
    modal.classList.add(OPENED_CLASS);
    modal.setAttribute("aria-hidden", "false");
    if (modal.tagName === "DIALOG") {
      if (typeof modal.showModal === "function") {
        try {
          modal.showModal();
        } catch (e) {
          if (!modal.hasAttribute("open")) {
            modal.setAttribute("open", "");
          }
        }
      } else if (!modal.hasAttribute("open")) {
        modal.setAttribute("open", "");
      }
    }
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
    resizeModal(modal);
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

  function resizeModal(modal) {
    window.requestAnimationFrame(function() {
      var modalBody = modal.querySelector(".fr-modal__body");
      var modalContent = modal.querySelector(".fr-modal__content");
      var modalHeader = modal.querySelector(".fr-modal__header");
      var modalFooter = modal.querySelector(".fr-modal__footer");
      if (!modalBody) return;

      var contentPadding = modalContent
        ? window.getComputedStyle(modalContent)
        : { paddingTop: "0", paddingBottom: "0" };

      var paddingTop = parseFloat(contentPadding.paddingTop) || 0;
      var paddingBottom = parseFloat(contentPadding.paddingBottom) || 0;
      var headerHeight = modalHeader ? modalHeader.offsetHeight : 0;
      var footerHeight = modalFooter ? modalFooter.offsetHeight : 0;

      var availableHeight =
        window.innerHeight - headerHeight - footerHeight - paddingTop - paddingBottom - 24;
      modalBody.style.maxHeight = Math.max(0, availableHeight) + "px";
    });
  }

  function prepareHiddenInputs(modal) {
    var ids = modal.dataset.ids.split(",");
    var container = document.getElementById("hidden-ids-container");

    container.innerHTML = "";

    ids.forEach(function(id) {
      var input = document.createElement("input");
      input.type = "hidden";
      input.name = "collection_selection[]";
      input.value = id;
      container.appendChild(input);
    });
  }

  function init() {
    var modal = document.getElementById(MODAL_ID);
    if (!modal) return;

    document.addEventListener("click", handleFusionClick, true);

    var form = document.getElementById("fusion-form");
    if (form) {
      form.addEventListener("submit", function() {
        prepareHiddenInputs(modal);
      });
    }
  }

  document.addEventListener("DOMContentLoaded", init);
})();
