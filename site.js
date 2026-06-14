(function () {
  var header = document.querySelector(".site-header");
  var toggle = document.querySelector("[data-nav-toggle]");

  if (header && toggle) {
    toggle.addEventListener("click", function () {
      header.classList.toggle("nav-open");
    });
  }

  var forms = document.querySelectorAll("[data-inquiry-form]");
  forms.forEach(function (form) {
    form.addEventListener("submit", function (event) {
      event.preventDefault();
      var status = form.querySelector("[data-form-status]");
      if (status) {
        status.textContent = "需求信息已整理。我们将根据您填写的联系方式沟通URS、招标文件或测试需求文档。";
      }
      form.classList.add("is-submitted");
    });
  });
})();
