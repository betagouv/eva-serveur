(function () {
  function clearButtonFor(fileInput) {
    var wrapper = fileInput.closest(".image-file-input-with-clear");
    if (!wrapper) {
      return null;
    }
    return wrapper.querySelector("[data-image-file-clear]");
  }

  function updateClearButtonVisibility(fileInput) {
    var btn = clearButtonFor(fileInput);
    if (!btn) {
      return;
    }
    if (fileInput.files && fileInput.files.length > 0) {
      btn.hidden = false;
    } else {
      btn.hidden = true;
    }
  }

  function onFileChange(event) {
    var target = event.target;
    if (!target.matches(".image-file-input-with-clear .fr-upload[type='file']")) {
      return;
    }
    updateClearButtonVisibility(target);
  }

  function onClearClick(event) {
    var btn = event.target.closest("[data-image-file-clear]");
    if (!btn) {
      return;
    }
    var wrapper = btn.closest(".image-file-input-with-clear");
    if (!wrapper) {
      return;
    }
    var fileInput = wrapper.querySelector(".fr-upload[type='file']");
    if (!fileInput) {
      return;
    }
    event.preventDefault();
    fileInput.value = "";
    btn.hidden = true;
    fileInput.dispatchEvent(new Event("change", { bubbles: true }));
  }

  document.addEventListener("change", onFileChange, true);
  document.addEventListener("click", onClearClick, true);
})();
