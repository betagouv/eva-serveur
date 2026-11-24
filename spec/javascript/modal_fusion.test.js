/**
 * @jest-environment jsdom
 */

const { init } = require("../../app/assets/javascripts/modal_fusion.js");

const MODAL_ID = "fr-modal-fusionner";
const FORM_ID = "beneficiaires-selection";

function ligne(id, nom, creeLe) {
  return `
    <tr>
      <th><input type="checkbox" name="beneficiaire_ids[]" value="${id}" /></th>
      <td><a data-nom>${nom}</a></td>
      <td><span data-created-at="${creeLe}"></span></td>
    </tr>`;
}

function ouvrirModalAvecIds(ids) {
  document.querySelectorAll('input[name="beneficiaire_ids[]"]').forEach((caseACocher) => {
    caseACocher.checked = ids.includes(caseACocher.value);
  });
  document.getElementById(MODAL_ID).dispatchEvent(new Event("dsfr.disclose"));
}

beforeEach(() => {
  document.body.innerHTML = `
    <form id="${FORM_ID}">
      <table><tbody>
        ${ligne("1", "Récente", "2025-03-01T10:00:00.000Z")}
        ${ligne("2", "Ancienne", "2024-01-01T10:00:00.000Z")}
        ${ligne("3", "Non cochée", "2020-01-01T10:00:00.000Z")}
      </tbody></table>
    </form>
    <div id="${MODAL_ID}" data-formulaire-selection="${FORM_ID}">
      <ul id="liste-elements-a-fusionner"></ul>
      <span id="beneficiaire-rattache"></span>
      <span id="beneficiaire-rattache-alert"></span>
    </div>
  `;
  init();
});

test("liste les bénéficiaires cochés, du plus ancien au plus récent", () => {
  ouvrirModalAvecIds(["1", "2"]);

  const noms = Array.from(document.querySelectorAll("#liste-elements-a-fusionner li"))
    .map((element) => element.textContent);
  expect(noms).toEqual(["Ancienne", "Récente"]);
});

test("annonce le rattachement au bénéficiaire le plus ancien", () => {
  ouvrirModalAvecIds(["1", "2"]);

  expect(document.getElementById("beneficiaire-rattache").textContent).toBe("Ancienne");
  expect(document.getElementById("beneficiaire-rattache-alert").textContent).toBe("Ancienne");
});

test("met la liste à jour à chaque ouverture", () => {
  ouvrirModalAvecIds(["1", "2"]);
  ouvrirModalAvecIds(["1", "3"]);

  const noms = Array.from(document.querySelectorAll("#liste-elements-a-fusionner li"))
    .map((element) => element.textContent);
  expect(noms).toEqual(["Non cochée", "Récente"]);
});
