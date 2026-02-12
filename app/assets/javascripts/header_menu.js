(function () {
  var MENU_ID = "header-menu";
  var BTN_ID = "header-menu-btn";
  var OPENED_CLASS = "fr-modal--opened";

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

  document.addEventListener("DOMContentLoaded", initHeaderMenu);
})();
