function toggleMenu() {
    document.getElementById('menu').classList.toggle('active');
  }

  let currentSlide = 0;
  const slides = document.querySelector('.slides');
  const totalSlides = document.querySelectorAll('.slide').length;

  function updateSlide() {
    slides.style.transform = `translateX(-${currentSlide * 100}%)`;
  }

  function nextSlide() {
    currentSlide = (currentSlide + 1) % totalSlides;
    updateSlide();
  }

  function prevSlide() {
    currentSlide = (currentSlide - 1 + totalSlides) % totalSlides;
    updateSlide();
  }

  setInterval(() => {
    nextSlide();
  }, 4000);

  function openTab(index) {
    const contents = document.querySelectorAll('.tab-content');
    contents.forEach((tab, i) => {
      tab.classList.toggle('active', i === index);
    });
  }

  