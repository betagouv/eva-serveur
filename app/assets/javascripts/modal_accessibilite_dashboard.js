(function(window) {
  var OPENED_CLASS = "fr-modal--opened";
  var SCROLL_LOCK_CLASS = "fr-modal-dashboard-evapro--scroll-locked";
  var FOCUSABLE_SELECTOR = [
    "a[href]",
    "button:not([disabled])",
    "textarea:not([disabled])",
    "input:not([disabled])",
    "select:not([disabled])",
    "[tabindex]:not([tabindex='-1'])"
  ].join(", ");

  var activeModal = null;
  var lastFocusedElement = null;
  var inertedElements = [];
  var keyboardBound = false;

  function isVisible(element) {
    if (!element) return false;
    return element.offsetParent !== null || element === document.activeElement;
  }

  function getFocusableElements(modal) {
    if (!modal) return [];
    return Array.prototype.slice
      .call(modal.querySelectorAll(FOCUSABLE_SELECTOR))
      .filter(function(element) {
        return isVisible(element) && !element.hasAttribute("disabled");
      });
  }

  function setPageScrollLocked(locked) {
    document.documentElement.classList.toggle(SCROLL_LOCK_CLASS, locked);
  }

  function setPageInert(modal, inert) {
    if (inert) {
      inertedElements = [];
      Array.prototype.slice.call(document.body.children).forEach(function(child) {
        if (child === modal) return;

        inertedElements.push({
          element: child,
          hadAriaHidden: child.hasAttribute("aria-hidden"),
          previousAriaHidden: child.getAttribute("aria-hidden")
        });

        child.setAttribute("inert", "");
        child.setAttribute("aria-hidden", "true");
      });
      return;
    }

    inertedElements.forEach(function(entry) {
      entry.element.removeAttribute("inert");
      if (entry.hadAriaHidden) {
        entry.element.setAttribute("aria-hidden", entry.previousAriaHidden);
      } else {
        entry.element.removeAttribute("aria-hidden");
      }
    });
    inertedElements = [];
  }

  function setModalOpen(modal, opened) {
    modal.classList.toggle(OPENED_CLASS, opened);
    modal.setAttribute("aria-hidden", opened ? "false" : "true");
    if (opened) {
      modal.setAttribute("aria-modal", "true");
    } else {
      modal.removeAttribute("aria-modal");
    }

    if (modal.tagName === "DIALOG") {
      if (opened) {
        modal.setAttribute("open", "");
      } else {
        modal.removeAttribute("open");
      }
    }
  }

  function closeActiveModal() {
    if (!activeModal) return;
    var modal = activeModal;
    setModalOpen(modal, false);
    activeModal = null;
    setPageInert(modal, false);
    setPageScrollLocked(false);

    if (lastFocusedElement && typeof lastFocusedElement.focus === "function") {
      lastFocusedElement.focus();
    }
  }

  function handleTabTrap(event) {
    if (!activeModal || event.key !== "Tab") return;

    var focusables = getFocusableElements(activeModal);
    if (focusables.length === 0) {
      event.preventDefault();
      var modalBody = activeModal.querySelector(".fr-modal__body") || activeModal;
      if (!modalBody.hasAttribute("tabindex")) {
        modalBody.setAttribute("tabindex", "-1");
      }
      modalBody.focus();
      return;
    }

    var first = focusables[0];
    var last = focusables[focusables.length - 1];
    var current = document.activeElement;

    if (!activeModal.contains(current)) {
      event.preventDefault();
      (event.shiftKey ? last : first).focus();
      return;
    }

    if (event.shiftKey && current === first) {
      event.preventDefault();
      last.focus();
      return;
    }

    if (!event.shiftKey && current === last) {
      event.preventDefault();
      first.focus();
    }
  }

  function bindKeyboardHandler() {
    if (keyboardBound) return;
    keyboardBound = true;

    document.addEventListener("keydown", function(event) {
      if (!activeModal || !activeModal.classList.contains(OPENED_CLASS)) return;
      if (event.key === "Escape") {
        event.preventDefault();
        closeActiveModal();
        return;
      }
      handleTabTrap(event);
    });
  }

  function openModal(modal) {
    if (!modal) return;
    if (activeModal && activeModal !== modal) {
      closeActiveModal();
    }

    lastFocusedElement = document.activeElement;
    setModalOpen(modal, true);
    activeModal = modal;
    setPageInert(modal, true);
    setPageScrollLocked(true);
  }

  window.GestionAccessibiliteModalesDashboard = {
    OPENED_CLASS: OPENED_CLASS,
    bindKeyboardHandler: bindKeyboardHandler,
    openModal: openModal,
    closeModal: function(modal) {
      if (modal && modal !== activeModal) {
        setModalOpen(modal, false);
        return;
      }
      closeActiveModal();
    }
  };
})(window);
