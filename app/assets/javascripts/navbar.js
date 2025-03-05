document.addEventListener("DOMContentLoaded", function () {
  const toggleButton = document.getElementById("navbarToggle");
  const menu = document.getElementById("navbarMenu");

  toggleButton.addEventListener("click", function () {
    menu.classList.toggle("navbar__menu--open");
  });
});
