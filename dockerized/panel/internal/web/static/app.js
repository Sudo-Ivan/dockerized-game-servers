(function () {
  if (!window.EventSource) {
    return;
  }
  var source = new EventSource('/events');
  source.addEventListener('status', function (event) {
    var panel = document.getElementById('status-panel');
    if (!panel) {
      return;
    }
    try {
      var data = JSON.parse(event.data);
      panel.innerHTML =
        '<div><strong>State:</strong> <span class="pill ' + data.State + '">' + data.State + '</span></div>' +
        '<div><strong>PID:</strong> ' + (data.PID || '-') + '</div>' +
        '<div><strong>Uptime:</strong> ' + (data.Uptime || '-') + '</div>' +
        '<div><strong>Mods:</strong> <code>' + (data.ModList || 'none') + '</code></div>' +
        (data.LastErr ? '<div class="flash err">' + data.LastErr + '</div>' : '');
    } catch (e) {}
  });
  source.addEventListener('sync', function (event) {
    var panel = document.getElementById('sync-panel');
    if (!panel) {
      return;
    }
    fetch('/mods/sync/status').then(function (r) { return r.text(); }).then(function (html) {
      panel.outerHTML = html;
    });
  });
  source.addEventListener('players', function (event) {
    var panel = document.getElementById('players-panel');
    if (!panel) {
      return;
    }
    fetch('/rcon/players').then(function (r) { return r.text(); }).then(function (html) {
      panel.innerHTML = html;
    });
  });
  source.addEventListener('logs', function (event) {
    var panel = document.getElementById('log-lines');
    if (!panel) {
      return;
    }
    var params = new URLSearchParams(window.location.search);
    var url = '/logs?partial=1';
    if (params.get('source')) {
      url += '&source=' + encodeURIComponent(params.get('source'));
    }
    if (params.get('filter')) {
      url += '&filter=' + encodeURIComponent(params.get('filter'));
    }
    fetch(url).then(function (r) { return r.text(); }).then(function (html) {
      panel.outerHTML = html;
    });
  });
})();
