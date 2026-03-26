(function () {
  var MENU_ID = "header-menu";
  var BTN_ID = "header-menu-btn";
  var OPENED_CLASS = "fr-modal--opened";
  var COLLAPSE_OPENED_CLASS = "fr-collapse--expanded";

  function openMenu(menu, btn) {
    menu.classList.add(OPENED_CLASS);
    btn.setAttribute("aria-expanded", "true");
    btn.setAttribute("data-fr-opened", "true");
  }

  function closeMenu(menu, btn) {
    menu.classList.remove(OPENED_CLASS);
    btn.setAttribute("aria-expanded", "false");
    btn.setAttribute("data-fr-opened", "false");
  }

  function toggleMenu(menu, btn) {
    if (menu.classList.contains(OPENED_CLASS)) {
      closeMenu(menu, btn);
    } else {
      openMenu(menu, btn);
    }
  }

  function initHeaderMenu() {
    var btn = document.getElementById(BTN_ID);
    var menu = document.getElementById(MENU_ID);
    if (!btn || !menu) return;

    btn.addEventListener("click", function (e) {
      e.stopImmediatePropagation();
      toggleMenu(menu, btn);
    }, true);

    var closeBtn = menu.querySelector(".fr-btn--close");
    if (closeBtn) {
      closeBtn.addEventListener("click", function (e) {
        e.preventDefault();
        e.stopImmediatePropagation();
        closeMenu(menu, btn);
      }, true);
    }

    menu.addEventListener("click", function (e) {
      if (e.target === menu) {
        closeMenu(menu, btn);
      }
    });

    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && menu.classList.contains(OPENED_CLASS)) {
        closeMenu(menu, btn);
        btn.focus();
      }
    });
  }

  function closeSiblingSubMenus(button) {
    var nav = button.closest(".fr-nav");
    if (!nav) return;

    var buttons = nav.querySelectorAll(".fr-nav__btn[aria-controls]");
    buttons.forEach(function (otherBtn) {
      if (otherBtn === button) return;
      var otherId = otherBtn.getAttribute("aria-controls");
      if (!otherId) return;

      var otherPanel = document.getElementById(otherId);
      if (otherPanel) {
        syncSubMenuState(otherBtn, otherPanel, false);
      }
    });
  }

  function syncSubMenuState(button, panel, expanded) {
    var titleBar = document.getElementById("title_bar");

    if (expanded) {
      panel.hidden = false;
      panel.setAttribute("aria-hidden", "false");
      panel.classList.add(COLLAPSE_OPENED_CLASS);
      panel.classList.remove("fr-collapsing");
      panel.style.pointerEvents = "auto";
      document.body.classList.add("dsfr-dropdown-open");
      if (titleBar) {
        titleBar.style.pointerEvents = "none";
      }
      button.setAttribute("aria-expanded", "true");
    } else {
      panel.hidden = true;
      panel.setAttribute("aria-hidden", "true");
      panel.classList.remove(COLLAPSE_OPENED_CLASS);
      panel.classList.remove("fr-collapsing");
      panel.style.pointerEvents = "";
      var hasOpenDropdown = document.querySelector(".fr-nav__btn[aria-expanded='true']");
      if (!hasOpenDropdown) {
        document.body.classList.remove("dsfr-dropdown-open");
      }
      if (titleBar && !hasOpenDropdown) {
        titleBar.style.pointerEvents = "";
      }
      button.setAttribute("aria-expanded", "false");
    }
  }

  function initNavigationDropdowns() {
    var buttons = document.querySelectorAll(".fr-nav__btn[aria-controls]");
    if (!buttons.length) return;

    buttons.forEach(function (button) {
      var panelId = button.getAttribute("aria-controls");
      if (!panelId) return;

      var panel = document.getElementById(panelId);
      if (!panel) return;

      syncSubMenuState(button, panel, button.getAttribute("aria-expanded") === "true");

      button.addEventListener("click", function (e) {
        e.preventDefault();
        var willOpen = button.getAttribute("aria-expanded") !== "true";
        closeSiblingSubMenus(button);
        syncSubMenuState(button, panel, willOpen);
      });
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    initHeaderMenu();
    initNavigationDropdowns();
  });
})();
