const menuToggle = document.querySelector(".menu-toggle");
const siteNav = document.querySelector(".site-nav");
const searchInput = document.querySelector("#paper-search");
const clearSearch = document.querySelector(".clear-search");
const chips = Array.from(document.querySelectorAll(".filter-chip"));
const cards = Array.from(document.querySelectorAll(".paper-card"));
const count = document.querySelector("#result-count");
const emptyState = document.querySelector(".empty-state");

let activeFilter = "all";

function normalize(value) {
  return value.toLowerCase().trim();
}

function applyFilters() {
  const query = normalize(searchInput.value);
  let visibleCount = 0;

  cards.forEach((card) => {
    const haystack = normalize(
      `${card.dataset.title || ""} ${card.dataset.tags || ""} ${card.textContent || ""}`,
    );
    const tagMatch = activeFilter === "all" || haystack.includes(activeFilter);
    const queryMatch = !query || haystack.includes(query);
    const isVisible = tagMatch && queryMatch;

    card.hidden = !isVisible;
    if (isVisible) visibleCount += 1;
  });

  count.textContent = `共 ${visibleCount} 篇白皮书`;
  emptyState.hidden = visibleCount !== 0;
  clearSearch.style.visibility = query ? "visible" : "hidden";
}

if (menuToggle && siteNav) {
  menuToggle.addEventListener("click", () => {
    const isOpen = siteNav.classList.toggle("open");
    menuToggle.setAttribute("aria-expanded", String(isOpen));
  });

  siteNav.addEventListener("click", (event) => {
    if (event.target.matches("a") && siteNav.classList.contains("open")) {
      siteNav.classList.remove("open");
      menuToggle.setAttribute("aria-expanded", "false");
    }
  });
}

chips.forEach((chip) => {
  chip.addEventListener("click", () => {
    activeFilter = chip.dataset.filter;
    chips.forEach((item) => {
      const isActive = item === chip;
      item.classList.toggle("active", isActive);
      item.setAttribute("aria-pressed", String(isActive));
    });
    applyFilters();
  });
});

searchInput.addEventListener("input", applyFilters);

clearSearch.addEventListener("click", () => {
  searchInput.value = "";
  searchInput.focus();
  applyFilters();
});

applyFilters();
