/**
 * @jest-environment jsdom
 */

const { init } = require("../../app/assets/javascripts/panneau_filtres.js");

let conceal;

function panneau() {
  return document.getElementById("filtres-panneau");
}

function ouvrir() {
  panneau().classList.add("fr-collapse--expanded");
}

beforeEach(() => {
  conceal = jest.fn();
  global.dsfr = jest.fn(() => ({ collapse: { conceal } }));
  document.body.innerHTML = `
    <div class="filtres__menu">
      <button id="bouton" aria-controls="filtres-panneau">Filtrer</button>
      <div id="filtres-panneau" class="fr-collapse filtres__panneau">
        <input id="dans-le-panneau" />
      </div>
    </div>
    <p id="ailleurs">Ailleurs</p>
  `;
  init();
});

test("ferme le panneau ouvert au clic en dehors", () => {
  ouvrir();

  document.getElementById("ailleurs").dispatchEvent(new MouseEvent("click", { bubbles: true }));

  expect(global.dsfr).toHaveBeenCalledWith(panneau());
  expect(conceal).toHaveBeenCalled();
});

test("garde le panneau ouvert au clic dedans", () => {
  ouvrir();

  document.getElementById("dans-le-panneau")
    .dispatchEvent(new MouseEvent("click", { bubbles: true }));

  expect(conceal).not.toHaveBeenCalled();
});

test("ferme le panneau ouvert avec Échap et rend le focus au bouton", () => {
  ouvrir();
  document.getElementById("dans-le-panneau").focus();

  document.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }));

  expect(conceal).toHaveBeenCalled();
  expect(document.activeElement.id).toBe("bouton");
});

test("ne fait rien quand le panneau est fermé", () => {
  document.getElementById("ailleurs").dispatchEvent(new MouseEvent("click", { bubbles: true }));
  document.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }));

  expect(conceal).not.toHaveBeenCalled();
});
