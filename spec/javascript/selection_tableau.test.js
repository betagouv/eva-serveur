/**
 * @jest-environment jsdom
 */

const { init } = require("../../app/assets/javascripts/selection_tableau.js");

const CLE_COMPTEUR = "components.tableau.lignes_selectionnees";

function cocher(valeur) {
  const caseACocher = document.querySelector(`input[value="${valeur}"]`);
  caseACocher.checked = !caseACocher.checked;
  caseACocher.dispatchEvent(new Event("change", { bubbles: true }));
}

function compteur() {
  return document.querySelector("[data-selection-compteur]").textContent;
}

function bouton(id) {
  return document.getElementById(id);
}

beforeEach(() => {
  global.I18n = { t: (cle, options) => `${cle} count=${options.count}` };
  document.body.innerHTML = `
    <form data-selection-tableau>
      <p data-selection-compteur></p>
      <button type="button" id="action-une" data-selection-minimum="1">Une</button>
      <button type="button" id="action-deux" data-selection-minimum="2">Deux</button>
      <input type="checkbox" data-fr-row-select="true" value="1" />
      <input type="checkbox" data-fr-row-select="true" value="2" checked />
      <input type="checkbox" data-fr-row-select="true" value="3" />
    </form>
  `;
  init();
});

test("compte les lignes déjà cochées au chargement", () => {
  expect(compteur()).toBe(`${CLE_COMPTEUR} count=1`);
});

test("active les actions dont le minimum de lignes est atteint", () => {
  expect(bouton("action-une").disabled).toBe(false);
  expect(bouton("action-deux").disabled).toBe(true);
});

test("met à jour le compteur et les actions quand on coche une ligne", () => {
  cocher("3");

  expect(compteur()).toBe(`${CLE_COMPTEUR} count=2`);
  expect(bouton("action-deux").disabled).toBe(false);
});

test("désactive toutes les actions quand plus rien n'est coché", () => {
  cocher("2");

  expect(compteur()).toBe(`${CLE_COMPTEUR} count=0`);
  expect(bouton("action-une").disabled).toBe(true);
});

test("suit les lignes d'un tableau remplacé après une recherche à la volée", () => {
  document.querySelector("[data-selection-tableau]").outerHTML = `
    <form data-selection-tableau>
      <p data-selection-compteur></p>
      <button type="button" id="action-une" data-selection-minimum="1">Une</button>
      <input type="checkbox" data-fr-row-select="true" value="8" />
    </form>
  `;
  document.dispatchEvent(new CustomEvent("resultats-actualises"));

  expect(compteur()).toBe(`${CLE_COMPTEUR} count=0`);
  expect(bouton("action-une").disabled).toBe(true);

  cocher("8");

  expect(compteur()).toBe(`${CLE_COMPTEUR} count=1`);
  expect(bouton("action-une").disabled).toBe(false);
});
