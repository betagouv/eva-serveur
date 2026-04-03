/**
 * Modales DSFR du tableau de bord admin : CGU (non acceptées) et comptes en attente.
 * Réouverture après init DSFR (ModalsGroup), verrouillage du scroll.
 * Fermeture au clic hors de la modale: sauf si data-dashboard-dsfr-backdrop-dismiss="false" (ex. CGU).
 */
(function() {
  var MODAL_IDS = [
    "fr-modal-confirmation-cgu",
    "fr-modal-validation-comptes-en-attente"
  ];
  var gestionAccessibiliteModalesDashboard = window.GestionAccessibiliteModalesDashboard;
  if (!gestionAccessibiliteModalesDashboard) return;

  function moveModalToBody(modal) {
    if (!modal || modal.parentNode === document.body) return;
    document.body.appendChild(modal);
  }

  function forceModalOpen(modal) {
    if (!modal) return;
    moveModalToBody(modal);
    gestionAccessibiliteModalesDashboard.openModal(modal);
  }

  function closeModal(modal) {
    if (!modal) return;
    gestionAccessibiliteModalesDashboard.closeModal(modal);
  }

  function bindModal(modal) {
    if (!modal || modal.getAttribute("data-dashboard-dsfr-modal-bound") === "true") {
      return;
    }
    modal.setAttribute("data-dashboard-dsfr-modal-bound", "true");

    var panel = modal.querySelector(".fr-modal__body");
    var backdropDismissAllowed =
      modal.getAttribute("data-dashboard-dsfr-backdrop-dismiss") !== "false";

    if (backdropDismissAllowed) {
      modal.addEventListener("click", function(event) {
        if (!panel || panel.contains(event.target)) return;
        event.preventDefault();
        closeModal(modal);
      });
    }

    var selectors =
      '[aria-controls="' + modal.id + '"], .fr-link--close, .fr-btn--close';
    modal.querySelectorAll(selectors).forEach(function(trigger) {
      trigger.addEventListener("click", function(event) {
        if (trigger.type === "submit") return;
        event.preventDefault();
        closeModal(modal);
      });
    });
  }

  function init() {
    gestionAccessibiliteModalesDashboard.bindKeyboardHandler();

    var modals = [];
    MODAL_IDS.forEach(function(id) {
      var modal = document.getElementById(id);
      if (modal) {
        modals.push(modal);
        bindModal(modal);
        forceModalOpen(modal);
      }
    });

    if (modals.length === 0) return;

    function bumpAll() {
      modals.forEach(forceModalOpen);
    }

    function afterPaint() {
      requestAnimationFrame(function() {
        requestAnimationFrame(bumpAll);
      });
    }

    if (document.readyState === "complete") {
      bumpAll();
      afterPaint();
    } else {
      window.addEventListener("load", function onLoad() {
        window.removeEventListener("load", onLoad);
        bumpAll();
        afterPaint();
      });
    }
  }

  document.addEventListener("DOMContentLoaded", init);
})();
