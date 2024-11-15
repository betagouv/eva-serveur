document.addEventListener("DOMContentLoaded", () => {
  const textareas = Array.from(document.getElementsByClassName("simple-mde-editor"));
  textareas.forEach(element => {
    new SimpleMDE({ element: element });
  }); 
});