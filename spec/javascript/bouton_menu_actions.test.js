/**
 * @jest-environment jsdom
 */

const { init } = require("../../app/assets/javascripts/bouton_menu_actions.js");

function cellule(id) {
  return `
    <td class="col-actions" id="${id}">
      <div class="menu-actions"><div class="table_actions"><a href="#">Voir</a></div></div>
    </td>`;
}

beforeEach(() => {
  global.I18n = { t: (cle) => cle };
  document.body.innerHTML = `<table><tbody id="lignes"><tr>${cellule("premiere")}</tr></tbody></table>`;
  init();
});

test("ajoute le bouton du menu d'actions à chaque ligne", () => {
  const bouton = document.querySelector("#premiere > button.bouton-menu");

  expect(bouton.getAttribute("aria-label")).toBe("components.bouton_menu_actions.label");
});

test("ouvre le menu au clic sur le bouton", () => {
  document.querySelector("#premiere > button.bouton-menu").click();

  expect(document.querySelector("#premiere .table_actions").classList).toContain("montrer");
});

test("équipe les lignes remplacées par la recherche à la volée, sans doubler les autres", () => {
  document.getElementById("lignes").insertAdjacentHTML("beforeend", `<tr>${cellule("nouvelle")}</tr>`);

  document.dispatchEvent(new CustomEvent("resultats-actualises"));

  expect(document.querySelectorAll("#nouvelle > button.bouton-menu")).toHaveLength(1);
  expect(document.querySelectorAll("#premiere > button.bouton-menu")).toHaveLength(1);
});
