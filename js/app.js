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

  function showNotification(message, type) {
    const notification = document.getElementById('notification');
    const messageEl = document.getElementById('notification-message');
    
    notification.className = 'notification ' + type;
    messageEl.textContent = message;
    notification.style.display = 'block';
    
    // Auto close after 5 seconds
    setTimeout(() => {
        closeNotification();
    }, 5000);
}

function closeNotification() {
    const notification = document.getElementById('notification');
    notification.style.display = 'none';
}

  document.getElementById('contactForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    
    fetch('process-contact.php', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification('¡Mensaje enviado correctamente!', 'success');
            this.reset();
        } else {
            showNotification(data.message || 'Error al enviar el mensaje', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Error de conexión: ' + error.message, 'error');
    });
});

