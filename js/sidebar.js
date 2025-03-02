const hamBurger = document.querySelector(".sidebar-btn-menu");

hamBurger.addEventListener("click", function () {
  document.querySelector("#sidebar").classList.toggle("expand");

  var icon = document.querySelector("#menu-btn-icon");

  if (icon.classList.contains("bi-list")) {
    icon.classList.remove("bi-list");
    icon.classList.add("bi-x-lg");
  } else {
    icon.classList.add("bi-list");
    icon.classList.remove("bi-x-lg");
  }
});
