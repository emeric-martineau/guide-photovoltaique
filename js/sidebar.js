const hamBurger = document.querySelector(".sidebar-btn-menu");

hamBurger.addEventListener("click", function () {
  document.querySelector("#sidebar").classList.toggle("expand");

  var icon = document.querySelector("#menu-btn-icon");

  if (icon.classList.contains("bi-list")) {
    /* Open menu */
    icon.classList.remove("bi-list");
    icon.classList.add("bi-x-lg");
    document.querySelector("#sidebar-footer").style.display = 'block';
  } else {
    /* Close menu */
    icon.classList.add("bi-list");
    icon.classList.remove("bi-x-lg");
    document.querySelector("#sidebar-footer").style.display = 'none';
  }
});
