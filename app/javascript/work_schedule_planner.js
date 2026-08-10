const root = document.querySelector("#work-schedule-planner");

if (root) {
  const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;
  const endpoints = {
    data: root.dataset.plannerDataUrl,
    saveShift: root.dataset.saveShiftUrl,
    deleteShift: root.dataset.deleteShiftUrl,
    saveDay: root.dataset.saveDayUrl,
    saveNotice: root.dataset.saveNoticeUrl,
    deleteNotice: root.dataset.deleteNoticeUrl,
    addStation: root.dataset.addStationUrl,
    removeStation: root.dataset.removeStationUrl,
    copyDay: root.dataset.copyDayUrl,
    duplicateSchedule: root.dataset.duplicateScheduleUrl,
    publish: root.dataset.publishUrl,
  };

  const state = {
    schedule: null,
    activeDayId: null,
    view: localStorage.getItem("seepalette-planner-view") || (matchMedia("(max-width: 767px)").matches ? "list" : "grid"),
    userFilter: "",
    stationFilter: "",
    selection: null,
    expandedNotices: new Set(),
  };

  const noticeLabels = {info: "Information", warning: "Warnung", critical: "Kritisch"};

  const escapeHtml = (value) => String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");

  const minuteLabel = (minute) => {
    const daySuffix = minute >= 1440 ? " (+1)" : "";
    const normalized = minute % 1440;
    return `${String(Math.floor(normalized / 60)).padStart(2, "0")}:${String(normalized % 60).padStart(2, "0")}${daySuffix}`;
  };

  const hourOptions = Array.from({length: 24}, (_, hour) => String(hour).padStart(2, "0"));
  const quarterOptions = ["00", "15", "30", "45"];

  function renderTimeField(name, label) {
    return `
      <fieldset class="planner-time-field">
        <legend>${label}</legend>
        <div class="planner-time-parts">
          <select name="${name}_hour" aria-label="${label} Stunde" required>${hourOptions.map((hour) => `<option value="${hour}">${hour}</option>`).join("")}</select>
          <span aria-hidden="true">:</span>
          <select name="${name}_minute" aria-label="${label} Minute" required>${quarterOptions.map((minute) => `<option value="${minute}">${minute}</option>`).join("")}</select>
        </div>
      </fieldset>
    `;
  }

  function setTimeValue(form, name, value) {
    const [hour = "00", minute = "00"] = value.split(":");
    form.elements[`${name}_hour`].value = hour;
    form.elements[`${name}_minute`].value = minute;
  }

  function timeValue(form, name) {
    return `${form.elements[`${name}_hour`].value}:${form.elements[`${name}_minute`].value}`;
  }

  const activeDay = () => state.schedule.days.find((day) => day.id === state.activeDayId) || state.schedule.days[0];
  const allShifts = (day) => day.stations.flatMap((station) => station.shifts.map((shift) => ({...shift, station})));
  const endpointMethod = (method, body) => ({
    method,
    headers: {"Accept": "application/json", "Content-Type": "application/json", "X-CSRF-Token": csrfToken},
    body: body ? JSON.stringify(body) : undefined,
  });

  async function request(url, options = {}) {
    const response = await fetch(url, options);
    if (response.ok) {
      if (response.status === 204) return null;
      return response.json();
    }

    let message = "Die Änderung konnte nicht gespeichert werden.";
    try {
      const payload = await response.json();
      if (payload.errors?.length) message = payload.errors.join("\n");
    } catch (_error) {
      // Keep the generic message when the server did not return JSON.
    }
    throw new Error(message);
  }

  async function refresh({preserveDay = true} = {}) {
    const payload = await request(endpoints.data, {headers: {"Accept": "application/json"}});
    const previousDay = preserveDay ? state.activeDayId : null;
    state.schedule = payload;
    state.activeDayId = payload.days.some((day) => day.id === previousDay) ? previousDay : payload.days[0]?.id;
    render();
  }

  function statusLabel() {
    return {
      draft: "Entwurf",
      published: `Veröffentlicht${state.schedule.latest_revision ? ` · Revision ${state.schedule.latest_revision}` : ""}`,
      changes_pending: "Unveröffentlichte Änderungen",
    }[state.schedule.publication_state] || state.schedule.publication_state;
  }

  function render() {
    const day = activeDay();
    root.innerHTML = `
      <section class="planner-shell">
        <header class="planner-toolbar">
          <div>
            <div class="planner-title-row">
              <h2>${escapeHtml(state.schedule.title)}</h2>
              <span class="planner-status planner-status--${escapeHtml(state.schedule.publication_state)}">${escapeHtml(statusLabel())}</span>
            </div>
            <p>${escapeHtml(state.schedule.starts_on)} – ${escapeHtml(state.schedule.ends_on)}</p>
          </div>
          <div class="planner-toolbar-actions">
            <button type="button" class="planner-button planner-button--secondary" data-action="duplicate-schedule">Plan kopieren</button>
            <button type="button" class="planner-button planner-button--primary" data-action="publish">${state.schedule.publication_state === "changes_pending" ? "Neu veröffentlichen" : "Veröffentlichen"}</button>
          </div>
        </header>

        <nav class="planner-day-tabs" aria-label="Tage im Dienstplan">
          ${state.schedule.days.map((item) => `<button type="button" class="planner-day-tab ${item.id === day.id ? "is-active" : ""}" data-action="select-day" data-day-id="${item.id}">${escapeHtml(item.label)}</button>`).join("")}
        </nav>

        <section class="planner-day-tools">
          <div class="planner-view-toggle" aria-label="Ansicht">
            <button type="button" data-action="set-view" data-view="grid" class="${state.view === "grid" ? "is-active" : ""}">Raster</button>
            <button type="button" data-action="set-view" data-view="list" class="${state.view === "list" ? "is-active" : ""}">Liste</button>
          </div>
          <div class="planner-day-actions">
            <button type="button" class="planner-button planner-button--secondary" data-action="day-settings">Zeitraum</button>
            <button type="button" class="planner-button planner-button--secondary" data-action="manage-stations">Stationen</button>
            <button type="button" class="planner-button planner-button--secondary" data-action="copy-day">Tag kopieren</button>
            <button type="button" class="planner-button planner-button--primary" data-action="new-shift">Schicht hinzufügen</button>
          </div>
        </section>

        ${renderNotices(day)}
        ${state.view === "grid" ? renderGrid(day) : renderList(day)}
      </section>
      ${renderDialogs()}
      <div class="planner-toast" role="status" aria-live="polite" hidden></div>
    `;
  }

  function renderNotices(day) {
    return `
      <section class="planner-notices" aria-label="Tageshinweise">
        <div class="planner-section-heading">
          <h3>Hinweise für diesen Tag</h3>
          <button type="button" class="planner-link-button" data-action="new-notice">+ Hinweis hinzufügen</button>
        </div>
        ${day.notices.length ? `<div class="planner-notice-list">${day.notices.map((notice) => {
          const expanded = state.expandedNotices.has(notice.id);
          const collapsible = notice.text.length > 220;
          return `
            <article class="planner-callout planner-callout--${escapeHtml(notice.severity)}">
              <header class="planner-callout-header">
                <span class="planner-callout-label">${escapeHtml(noticeLabels[notice.severity] || notice.severity)}</span>
                <button type="button" class="planner-link-button" data-action="edit-notice" data-notice-id="${notice.id}">Bearbeiten</button>
              </header>
              <p class="planner-callout-text ${expanded ? "is-expanded" : ""}">${escapeHtml(notice.text)}</p>
              ${collapsible ? `<button type="button" class="planner-callout-toggle" data-action="toggle-notice" data-notice-id="${notice.id}" aria-expanded="${expanded}">${expanded ? "Weniger anzeigen" : "Mehr anzeigen"}</button>` : ""}
            </article>
          `;
        }).join("")}</div>` : `<p class="planner-empty-inline">Keine Hinweise hinterlegt.</p>`}
      </section>
    `;
  }

  function renderGrid(day) {
    if (!day.stations.length) return `
      <div class="planner-empty">
        <p>Aktiviere mindestens eine Station, um das Raster zu verwenden.</p>
        <button type="button" class="planner-button planner-button--secondary" data-action="manage-stations">Stationen verwalten</button>
      </div>
    `;

    const maximumShiftEnd = Math.max(day.grid_end_minute, ...allShifts(day).map(({end_minute: end}) => end));
    const gridEnd = Math.ceil(maximumShiftEnd / 15) * 15;
    const slotCount = (gridEnd - day.grid_start_minute) / 15;
    const columnTemplate = `72px repeat(${day.stations.length}, minmax(138px, 1fr))`;
    const rows = [];
    for (let index = 0; index < slotCount; index += 1) {
      const minute = day.grid_start_minute + index * 15;
      rows.push(`<div class="planner-time-label" style="grid-column:1;grid-row:${index + 2}">${minute % 60 === 0 ? minuteLabel(minute) : ""}</div>`);
      day.stations.forEach((station, stationIndex) => {
        rows.push(`<div class="planner-grid-cell" data-minute="${minute}" data-station-id="${station.id}" style="grid-column:${stationIndex + 2};grid-row:${index + 2}"></div>`);
      });
    }

    const shifts = day.stations.flatMap((station, stationIndex) => station.shifts.map((shift) => {
      const startRow = Math.max(0, (shift.start_minute - day.grid_start_minute) / 15) + 2;
      const endRow = Math.min(slotCount, (shift.end_minute - day.grid_start_minute) / 15) + 2;
      return `<button type="button" class="planner-shift-block planner-user-color--${escapeHtml(shift.user_color)}" data-action="edit-shift" data-shift-id="${shift.id}" data-station-id="${station.id}" style="grid-column:${stationIndex + 2};grid-row:${startRow}/${endRow}">
        <strong>${escapeHtml(shift.user_name)}</strong>
        <span>${escapeHtml(shift.start_time)}–${escapeHtml(shift.end_time)}${shift.overnight ? " +1" : ""}</span>
      </button>`;
    })).join("");

    return `
      <section class="planner-grid-scroll" aria-label="Dienstplanraster">
        <div class="planner-grid" style="grid-template-columns:${columnTemplate};grid-template-rows:42px repeat(${slotCount}, 22px)">
          <div class="planner-grid-corner" style="grid-column:1;grid-row:1">Zeit</div>
          ${day.stations.map((station, index) => `<div class="planner-station-header" style="grid-column:${index + 2};grid-row:1">${escapeHtml(station.name)}</div>`).join("")}
          ${rows.join("")}
          ${shifts}
        </div>
      </section>
    `;
  }

  function renderList(day) {
    const userOptions = state.schedule.users.map((user) => `<option value="${user.id}" ${String(user.id) === state.userFilter ? "selected" : ""}>${escapeHtml(user.name)}</option>`).join("");
    const stationOptions = day.stations.map((station) => `<option value="${station.id}" ${String(station.id) === state.stationFilter ? "selected" : ""}>${escapeHtml(station.name)}</option>`).join("");
    const shifts = allShifts(day)
      .filter((shift) => !state.userFilter || String(shift.user_id) === state.userFilter)
      .filter((shift) => !state.stationFilter || String(shift.station.id) === state.stationFilter)
      .sort((left, right) => left.starts_at.localeCompare(right.starts_at));

    return `
      <section class="planner-list" aria-label="Schichtliste">
        <div class="planner-list-filters">
          <label>Mitarbeiter/in<select data-action="filter-user"><option value="">Alle</option>${userOptions}</select></label>
          <label>Station<select data-action="filter-station"><option value="">Alle</option>${stationOptions}</select></label>
        </div>
        ${shifts.length ? `<div class="planner-shift-list">
          <div class="planner-shift-list-header" aria-hidden="true">
            <span>Zeit</span>
            <span>Mitarbeiter/in</span>
            <span>Station</span>
            <span>Notiz</span>
          </div>
          ${shifts.map((shift) => `
          <button type="button" class="planner-shift-card planner-user-color--${escapeHtml(shift.user_color)}" data-action="edit-shift" data-shift-id="${shift.id}" data-station-id="${shift.station.id}">
            <span class="planner-shift-time">${escapeHtml(shift.start_time)}–${escapeHtml(shift.end_time)}${shift.overnight ? " <em>Folgetag</em>" : ""}</span>
            <strong class="planner-shift-person">${escapeHtml(shift.user_name)}</strong>
            <span class="planner-shift-station">${escapeHtml(shift.station.name)}</span>
            <span class="planner-shift-meta">${shift.notes ? escapeHtml(shift.notes) : "Keine Notiz"}</span>
          </button>
        `).join("")}</div>` : `
          <div class="planner-empty">
            <p>Für diesen Tag und Filter gibt es noch keine Schichten.</p>
            <button type="button" class="planner-button planner-button--primary" data-action="new-shift">Schicht hinzufügen</button>
          </div>
        `}
      </section>
    `;
  }

  function renderDialogs() {
    const dateOptions = state.schedule.days.map((day) => `<option value="${day.date}">${escapeHtml(day.label)}</option>`).join("");
    const targetDayOptions = state.schedule.days.filter((day) => day.id !== activeDay().id).map((day) => `<option value="${day.id}">${escapeHtml(day.label)}</option>`).join("");
    return `
      <dialog class="planner-dialog planner-dialog--shift" id="shift-dialog" aria-labelledby="shift-dialog-title">
        <form method="dialog" id="shift-form">
          <header><h3 id="shift-dialog-title">Schicht anlegen</h3><button type="button" class="planner-dialog-close" data-action="close-dialog" aria-label="Schließen">×</button></header>
          <div class="planner-dialog-body">
            <input type="hidden" name="shift_id">
            <div class="planner-form-grid">
              <label class="planner-field planner-field--wide">Mitarbeiter/in<select name="user_id" required>${state.schedule.users.map((user) => `<option value="${user.id}">${escapeHtml(user.name)}</option>`).join("")}</select></label>
              <label class="planner-field">Datum<select name="date" required>${dateOptions}</select></label>
              <label class="planner-field">Station<select name="day_station_id" required></select></label>
              ${renderTimeField("start", "Start")}
              ${renderTimeField("end", "Ende")}
              <label class="planner-check planner-field--wide"><input type="checkbox" name="overnight"> Endet am Folgetag</label>
              <label class="planner-field planner-field--wide">Notiz<textarea name="notes" rows="3"></textarea></label>
            </div>
            <p class="planner-form-error" hidden></p>
          </div>
          <footer>
            <button type="button" class="planner-button planner-button--danger" data-action="delete-shift" hidden>Löschen</button>
            <span class="planner-dialog-spacer"></span>
            <button type="button" class="planner-button planner-button--secondary" data-action="close-dialog">Abbrechen</button>
            <button type="submit" class="planner-button planner-button--secondary" value="new">Speichern & weitere</button>
            <button type="submit" class="planner-button planner-button--primary" value="close">Speichern</button>
          </footer>
        </form>
      </dialog>

      <dialog class="planner-dialog planner-dialog--compact" id="notice-dialog" aria-labelledby="notice-dialog-title">
        <form method="dialog" id="notice-form">
          <header><h3 id="notice-dialog-title">Tageshinweis</h3><button type="button" class="planner-dialog-close" data-action="close-dialog" aria-label="Schließen">×</button></header>
          <div class="planner-dialog-body">
            <input type="hidden" name="notice_id">
            <label class="planner-field">Art<select name="severity" required><option value="info">Information</option><option value="warning">Warnung</option><option value="critical">Kritisch</option></select></label>
            <label class="planner-field">Hinweis<textarea name="text" rows="4" required></textarea></label>
            <p class="planner-form-error" hidden></p>
          </div>
          <footer><button type="button" class="planner-button planner-button--danger" data-action="delete-notice" hidden>Löschen</button><span class="planner-dialog-spacer"></span><button type="button" class="planner-button planner-button--secondary" data-action="close-dialog">Abbrechen</button><button type="submit" class="planner-button planner-button--primary">Speichern</button></footer>
        </form>
      </dialog>

      <dialog class="planner-dialog planner-dialog--medium" id="station-dialog" aria-labelledby="station-dialog-title">
        <form method="dialog" id="station-form">
          <header><h3 id="station-dialog-title">Stationen verwalten</h3><button type="button" class="planner-dialog-close" data-action="close-dialog" aria-label="Schließen">×</button></header>
          <div class="planner-dialog-body">
            <div class="planner-active-stations">${activeDay().stations.map((station) => `<span>${escapeHtml(station.name)} <button type="button" data-action="remove-station" data-station-id="${station.id}" aria-label="${escapeHtml(station.name)} entfernen">×</button></span>`).join("")}</div>
            <label class="planner-field">Vorhandene Station<select name="station_id"><option value="">Neue Station …</option>${state.schedule.stations.filter((station) => !activeDay().stations.some((item) => item.station_id === station.id)).map((station) => `<option value="${station.id}">${escapeHtml(station.name)}</option>`).join("")}</select></label>
            <label class="planner-field">Name der neuen Station<input type="text" name="name"></label>
            <label class="planner-field">Gültigkeit<select name="scope"><option value="day">Nur dieser Tag</option><option value="catalog">Im Stationskatalog speichern</option></select></label>
            <label class="planner-check"><input type="checkbox" name="default_enabled"> Bei neuen Tagen standardmäßig aktiv</label>
            <p class="planner-form-error" hidden></p>
          </div>
          <footer><span class="planner-dialog-spacer"></span><button type="button" class="planner-button planner-button--secondary" data-action="close-dialog">Schließen</button><button type="submit" class="planner-button planner-button--primary">Station hinzufügen</button></footer>
        </form>
      </dialog>

      <dialog class="planner-dialog planner-dialog--compact" id="day-settings-dialog" aria-labelledby="day-settings-dialog-title">
        <form method="dialog" id="day-settings-form">
          <header><h3 id="day-settings-dialog-title">Sichtbarer Zeitraum</h3><button type="button" class="planner-dialog-close" data-action="close-dialog" aria-label="Schließen">×</button></header>
          <div class="planner-dialog-body">
            <div class="planner-form-grid">${renderTimeField("start", "Beginn")}${renderTimeField("end", "Ende")}</div>
            <label class="planner-check"><input type="checkbox" name="overnight"> Ende liegt am Folgetag</label>
            <p class="planner-form-error" hidden></p>
          </div>
          <footer><span class="planner-dialog-spacer"></span><button type="button" class="planner-button planner-button--secondary" data-action="close-dialog">Abbrechen</button><button type="submit" class="planner-button planner-button--primary">Speichern</button></footer>
        </form>
      </dialog>

      <dialog class="planner-dialog planner-dialog--compact" id="copy-day-dialog" aria-labelledby="copy-day-dialog-title">
        <form method="dialog" id="copy-day-form">
          <header><h3 id="copy-day-dialog-title">Tag kopieren</h3><button type="button" class="planner-dialog-close" data-action="close-dialog" aria-label="Schließen">×</button></header>
          <div class="planner-dialog-body">
            <label class="planner-field">Zieltag<select name="target_day_id" required>${targetDayOptions}</select></label>
            <label class="planner-check"><input type="checkbox" name="include_stations" checked> Stationen ergänzen</label>
            <label class="planner-check"><input type="checkbox" name="include_notices" checked> Hinweise ergänzen</label>
            <label class="planner-check"><input type="checkbox" name="include_shifts"> Schichten inklusive Mitarbeitenden ergänzen</label>
            <p class="planner-form-error" hidden></p>
          </div>
          <footer><span class="planner-dialog-spacer"></span><button type="button" class="planner-button planner-button--secondary" data-action="close-dialog">Abbrechen</button><button type="submit" class="planner-button planner-button--primary">Kopieren</button></footer>
        </form>
      </dialog>

      <dialog class="planner-dialog planner-dialog--compact" id="duplicate-dialog" aria-labelledby="duplicate-dialog-title">
        <form method="dialog" id="duplicate-form">
          <header><h3 id="duplicate-dialog-title">Dienstplan kopieren</h3><button type="button" class="planner-dialog-close" data-action="close-dialog" aria-label="Schließen">×</button></header>
          <div class="planner-dialog-body">
            <label class="planner-field">Neues Startdatum<input type="date" name="starts_on" required></label>
            <label class="planner-check"><input type="checkbox" name="include_stations" checked> Stationen übernehmen</label>
            <label class="planner-check"><input type="checkbox" name="include_notices" checked> Hinweise übernehmen</label>
            <label class="planner-check"><input type="checkbox" name="include_shifts"> Schichten inklusive Mitarbeitenden übernehmen</label>
            <p class="planner-form-error" hidden></p>
          </div>
          <footer><span class="planner-dialog-spacer"></span><button type="button" class="planner-button planner-button--secondary" data-action="close-dialog">Abbrechen</button><button type="submit" class="planner-button planner-button--primary">Plan anlegen</button></footer>
        </form>
      </dialog>
    `;
  }

  function showDialog(id, focusSelector = "input:not([type='hidden']), select, textarea") {
    const dialog = document.querySelector(id);
    if (!dialog) return;

    dialog.showModal();
    window.requestAnimationFrame(() => dialog.querySelector(focusSelector)?.focus({preventScroll: true}));
  }

  function closeDialog(element) {
    element.closest("dialog")?.close();
  }

  function setFormError(form, error) {
    const target = form.querySelector(".planner-form-error");
    target.textContent = error.message;
    target.hidden = false;
  }

  function updateShiftStationOptions(form, selectedId = null) {
    const day = state.schedule.days.find((item) => item.date === form.elements.date.value);
    const select = form.elements.day_station_id;
    select.innerHTML = (day?.stations || []).map((station) => `<option value="${station.id}" ${String(station.id) === String(selectedId) ? "selected" : ""}>${escapeHtml(station.name)}</option>`).join("");
  }

  function findShift(id) {
    for (const day of state.schedule.days) {
      for (const station of day.stations) {
        const shift = station.shifts.find((item) => item.id === Number(id));
        if (shift) return {day, station, shift};
      }
    }
    return null;
  }

  function openShiftForm({shift = null, day = activeDay(), stationId = null, startMinute = null, endMinute = null} = {}) {
    const dialog = document.querySelector("#shift-dialog");
    const form = dialog.querySelector("form");
    form.reset();
    form.querySelector(".planner-form-error").hidden = true;
    form.elements.shift_id.value = shift?.id || "";
    form.elements.date.value = day.date;
    updateShiftStationOptions(form, stationId);
    form.elements.user_id.value = shift?.user_id || state.schedule.users[0]?.id || "";
    setTimeValue(form, "start", shift?.start_time || minuteLabel(startMinute ?? day.grid_start_minute).slice(0, 5));
    setTimeValue(form, "end", shift?.end_time || minuteLabel(endMinute ?? day.grid_start_minute + 60).slice(0, 5));
    form.elements.overnight.checked = shift?.overnight || (endMinute ?? 0) >= 1440;
    form.elements.notes.value = shift?.notes || "";
    form.querySelector("[data-action='delete-shift']").hidden = !shift;
    dialog.querySelector("#shift-dialog-title").textContent = shift ? "Schicht bearbeiten" : "Schicht anlegen";
    showDialog("#shift-dialog", "[name='user_id']");
  }

  function showToast(message) {
    const toast = document.querySelector(".planner-toast");
    if (!toast) return;
    toast.textContent = message;
    toast.hidden = false;
    window.setTimeout(() => { toast.hidden = true; }, 2600);
  }

  root.addEventListener("pointerdown", (event) => {
    const cell = event.target.closest(".planner-grid-cell");
    if (!cell) return;
    state.selection = {stationId: Number(cell.dataset.stationId), start: Number(cell.dataset.minute)};
  });

  root.addEventListener("pointerup", (event) => {
    const cell = event.target.closest(".planner-grid-cell");
    if (!cell || !state.selection || Number(cell.dataset.stationId) !== state.selection.stationId) {
      state.selection = null;
      return;
    }
    const end = Number(cell.dataset.minute);
    const startMinute = Math.min(state.selection.start, end);
    const endMinute = Math.max(state.selection.start, end) + 15;
    openShiftForm({stationId: state.selection.stationId, startMinute, endMinute});
    state.selection = null;
  });

  root.addEventListener("change", (event) => {
    if (event.target.matches("[data-action='filter-user']")) {
      state.userFilter = event.target.value;
      render();
    } else if (event.target.matches("[data-action='filter-station']")) {
      state.stationFilter = event.target.value;
      render();
    } else if (event.target.matches("#shift-form [name='date']")) {
      updateShiftStationOptions(event.target.form);
    }
  });

  root.addEventListener("click", async (event) => {
    const trigger = event.target.closest("[data-action]");
    if (!trigger) return;
    const action = trigger.dataset.action;
    try {
      if (action === "select-day") {
        state.activeDayId = Number(trigger.dataset.dayId);
        state.userFilter = "";
        state.stationFilter = "";
        render();
      } else if (action === "set-view") {
        state.view = trigger.dataset.view;
        localStorage.setItem("seepalette-planner-view", state.view);
        render();
      } else if (action === "new-shift") {
        openShiftForm();
      } else if (action === "edit-shift") {
        const result = findShift(trigger.dataset.shiftId);
        if (result) openShiftForm({shift: result.shift, day: result.day, stationId: result.station.id});
      } else if (action === "close-dialog") {
        closeDialog(trigger);
      } else if (action === "toggle-notice") {
        const noticeId = Number(trigger.dataset.noticeId);
        if (state.expandedNotices.has(noticeId)) state.expandedNotices.delete(noticeId);
        else state.expandedNotices.add(noticeId);
        render();
      } else if (action === "new-notice") {
        const form = document.querySelector("#notice-form");
        form.reset();
        form.elements.notice_id.value = "";
        form.elements.severity.value = "info";
        form.querySelector("[data-action='delete-notice']").hidden = true;
        showDialog("#notice-dialog", "[name='text']");
      } else if (action === "edit-notice") {
        const notice = activeDay().notices.find((item) => item.id === Number(trigger.dataset.noticeId));
        const form = document.querySelector("#notice-form");
        form.elements.notice_id.value = notice.id;
        form.elements.severity.value = notice.severity;
        form.elements.text.value = notice.text;
        form.querySelector("[data-action='delete-notice']").hidden = false;
        showDialog("#notice-dialog", "[name='text']");
      } else if (action === "manage-stations") {
        showDialog("#station-dialog");
      } else if (action === "day-settings") {
        const form = document.querySelector("#day-settings-form");
        setTimeValue(form, "start", minuteLabel(activeDay().grid_start_minute).slice(0, 5));
        setTimeValue(form, "end", minuteLabel(activeDay().grid_end_minute).slice(0, 5));
        form.elements.overnight.checked = activeDay().grid_end_minute >= 1440;
        showDialog("#day-settings-dialog");
      } else if (action === "copy-day") {
        showDialog("#copy-day-dialog");
      } else if (action === "duplicate-schedule") {
        showDialog("#duplicate-dialog");
      } else if (action === "remove-station") {
        await request(endpoints.removeStation, endpointMethod("DELETE", {day_station_id: trigger.dataset.stationId}));
        await refresh();
        showDialog("#station-dialog");
      } else if (action === "delete-shift") {
        const form = trigger.closest("form");
        if (!confirm("Diese Schicht wirklich löschen?")) return;
        await request(endpoints.deleteShift, endpointMethod("DELETE", {shift_id: form.elements.shift_id.value}));
        closeDialog(trigger);
        await refresh();
        showToast("Schicht gelöscht");
      } else if (action === "delete-notice") {
        const form = trigger.closest("form");
        await request(endpoints.deleteNotice, endpointMethod("DELETE", {day_id: activeDay().id, notice_id: form.elements.notice_id.value}));
        closeDialog(trigger);
        await refresh();
      } else if (action === "publish") {
        await request(endpoints.publish, endpointMethod("POST", {}));
        await refresh();
        showToast("Dienstplan veröffentlicht");
      }
    } catch (error) {
      const form = trigger.closest("form");
      if (form) setFormError(form, error);
      else alert(error.message);
    }
  });

  root.addEventListener("submit", async (event) => {
    event.preventDefault();
    const form = event.target;
    const values = Object.fromEntries(new FormData(form));
    form.querySelector(".planner-form-error").hidden = true;
    try {
      if (form.id === "shift-form") {
        const keepOpen = event.submitter?.value === "new";
        const shiftValues = {...values, start_time: timeValue(form, "start"), end_time: timeValue(form, "end")};
        ["start_hour", "start_minute", "end_hour", "end_minute"].forEach((key) => delete shiftValues[key]);
        await request(endpoints.saveShift, endpointMethod("POST", {
          shift_id: values.shift_id || null,
          shift: {...shiftValues, overnight: form.elements.overnight.checked},
        }));
        form.closest("dialog").close();
        await refresh();
        showToast("Schicht gespeichert");
        if (keepOpen) openShiftForm({day: activeDay()});
      } else if (form.id === "notice-form") {
        await request(endpoints.saveNotice, endpointMethod("POST", {day_id: activeDay().id, notice_id: values.notice_id || null, notice: {text: values.text, severity: values.severity}}));
        form.closest("dialog").close();
        await refresh();
      } else if (form.id === "station-form") {
        await request(endpoints.addStation, endpointMethod("POST", {
          day_id: activeDay().id,
          day_station: {...values, default_enabled: form.elements.default_enabled.checked},
        }));
        form.closest("dialog").close();
        await refresh();
        showDialog("#station-dialog");
      } else if (form.id === "day-settings-form") {
        const toMinute = (time) => Number(time.split(":")[0]) * 60 + Number(time.split(":")[1]);
        const startTime = timeValue(form, "start");
        const endTime = timeValue(form, "end");
        const end = toMinute(endTime) + (form.elements.overnight.checked ? 1440 : 0);
        await request(endpoints.saveDay, endpointMethod("PATCH", {day_id: activeDay().id, day: {grid_start_minute: toMinute(startTime), grid_end_minute: end}}));
        form.closest("dialog").close();
        await refresh();
      } else if (form.id === "copy-day-form") {
        await request(endpoints.copyDay, endpointMethod("POST", {
          source_day_id: activeDay().id,
          target_day_id: values.target_day_id,
          include_stations: form.elements.include_stations.checked,
          include_notices: form.elements.include_notices.checked,
          include_shifts: form.elements.include_shifts.checked,
        }));
        form.closest("dialog").close();
        await refresh();
        showToast("Tag kopiert");
      } else if (form.id === "duplicate-form") {
        const result = await request(endpoints.duplicateSchedule, endpointMethod("POST", {
          starts_on: values.starts_on,
          include_stations: form.elements.include_stations.checked,
          include_notices: form.elements.include_notices.checked,
          include_shifts: form.elements.include_shifts.checked,
        }));
        window.location.assign(result.location);
      }
    } catch (error) {
      setFormError(form, error);
    }
  });

  refresh({preserveDay: false}).catch((error) => {
    root.innerHTML = `<div class="planner-empty planner-error">${escapeHtml(error.message)}</div>`;
  });
}
