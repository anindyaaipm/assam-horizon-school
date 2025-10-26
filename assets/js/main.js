document.addEventListener('DOMContentLoaded', function() {
  var yearEl = document.getElementById('year');
  if (yearEl) {
    yearEl.textContent = new Date().getFullYear();
  }

  var lightboxModalEl = document.getElementById('lightboxModal');
  var lightboxImgEl = document.getElementById('lightboxImg');
  if (lightboxModalEl && lightboxImgEl && window.bootstrap) {
    var modal = new bootstrap.Modal(lightboxModalEl);
    document.querySelectorAll('[data-gallery="image"]').forEach(function(img) {
      img.addEventListener('click', function() {
        lightboxImgEl.src = img.getAttribute('data-src') || img.src;
        lightboxImgEl.alt = img.alt || 'Gallery image';
        modal.show();
      });
    });

    lightboxModalEl.addEventListener('hidden.bs.modal', function() {
      lightboxImgEl.src = '';
      lightboxImgEl.alt = '';
    });
  }
});





