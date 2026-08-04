---
title: Arma 3 Config Generator
description: Build a server.cfg for the Arma 3 dedicated server image in your browser.
---

Use the form below to create a server.cfg for the [Arma 3 server](../servers/arma-3/). The preview updates as you type. Copy or download the file when you are ready.

:::note[Client-side only]
Everything runs in your browser. Nothing is sent to a server.
:::

<div id="a3cfg-tool" class="a3cfg-tool" data-tool>
<form id="a3cfg-form" class="a3cfg-form">
<fieldset class="a3cfg-fieldset">
<legend>Global settings</legend>

<label class="a3cfg-field">
<span>Hostname</span>
<input type="text" id="a3cfg-hostname" value="My Arma 3 Server" maxlength="200" />
</label>

<label class="a3cfg-field">
<span>Server password <small>(blank = none)</small></span>
<input type="text" id="a3cfg-password" value="" />
</label>

<label class="a3cfg-field">
<span>Admin password</span>
<input type="text" id="a3cfg-passwordAdmin" value="changeme" />
</label>

<label class="a3cfg-field">
<span>Server commands password <small>(blank = same as admin)</small></span>
<input type="text" id="a3cfg-serverCommandPassword" value="" />
</label>

<label class="a3cfg-field a3cfg-field-wide">
<span>Message of the day <small>(one line per message)</small></span>
<textarea id="a3cfg-motd" rows="3">Welcome to the server.
Have fun and follow the rules.</textarea>
</label>

<label class="a3cfg-field">
<span>MOTD interval (seconds)</span>
<input type="number" id="a3cfg-motdInterval" value="30" min="0" />
</label>
</fieldset>

<fieldset class="a3cfg-fieldset">
<legend>Connection settings</legend>

<label class="a3cfg-field">
<span>Max players</span>
<input type="number" id="a3cfg-maxPlayers" value="32" min="1" max="300" />
</label>

<label class="a3cfg-field a3cfg-checkbox">
<input type="checkbox" id="a3cfg-kickDuplicate" checked />
<span>Kick duplicate player IDs</span>
</label>

<label class="a3cfg-field">
<span>Verify signatures</span>
<select id="a3cfg-verifySignatures">
<option value="0">Disabled</option>
<option value="2" selected>Full protection</option>
</select>
</label>

<label class="a3cfg-field">
<span>Allow file patching</span>
<select id="a3cfg-allowedFilePatching">
<option value="0" selected>No clients</option>
<option value="1">Headless clients only</option>
<option value="2">All clients</option>
</select>
</label>

<label class="a3cfg-field">
<span>Disconnect timeout (seconds)</span>
<input type="number" id="a3cfg-disconnectTimeout" value="90" min="5" max="90" />
</label>

<label class="a3cfg-field">
<span>Max desync (ms) <small>(blank = engine default)</small></span>
<input type="number" id="a3cfg-maxDesync" value="" min="0" />
</label>

<label class="a3cfg-field">
<span>Max ping (ms) <small>(blank = engine default)</small></span>
<input type="number" id="a3cfg-maxPing" value="" min="0" />
</label>

<label class="a3cfg-field">
<span>Max packet loss <small>(blank = engine default)</small></span>
<input type="number" id="a3cfg-maxPacketLoss" value="" min="0" />
</label>
</fieldset>

<fieldset class="a3cfg-fieldset">
<legend>In-game settings</legend>

<label class="a3cfg-field a3cfg-checkbox">
<input type="checkbox" id="a3cfg-battlEye" checked />
<span>Enable BattlEye</span>
</label>

<label class="a3cfg-field a3cfg-checkbox">
<input type="checkbox" id="a3cfg-persistent" checked />
<span>Persistent mission (keep running with no players)</span>
</label>

<label class="a3cfg-field a3cfg-checkbox">
<input type="checkbox" id="a3cfg-disableVoN" />
<span>Disable voice over net</span>
</label>

<label class="a3cfg-field">
<span>VoN codec</span>
<select id="a3cfg-vonCodec">
<option value="0">SPEEX</option>
<option value="1" selected>OPUS</option>
</select>
</label>

<label class="a3cfg-field">
<span>VoN codec quality <small>(1-20 OPUS, 1-10 SPEEX)</small></span>
<input type="number" id="a3cfg-vonCodecQuality" value="15" min="1" max="20" />
</label>

<label class="a3cfg-field">
<span>Vote threshold <small>(0-1)</small></span>
<input type="number" id="a3cfg-voteThreshold" value="0.33" min="0" max="1" step="0.01" />
</label>

<label class="a3cfg-field">
<span>Vote mission players</span>
<input type="number" id="a3cfg-voteMissionPlayers" value="1" min="0" />
</label>
</fieldset>

<fieldset class="a3cfg-fieldset">
<legend>Log settings</legend>

<label class="a3cfg-field">
<span>Log file</span>
<input type="text" id="a3cfg-logFile" value="server_console.log" />
</label>

<label class="a3cfg-field">
<span>Timestamp format</span>
<select id="a3cfg-timeStampFormat">
<option value="none">None</option>
<option value="short" selected>Short</option>
<option value="full">Full</option>
</select>
</label>
</fieldset>
</form>

<div class="a3cfg-output">
<div class="a3cfg-output-head">
<span>server.cfg</span>
<div class="a3cfg-actions">
<button type="button" id="a3cfg-copy">Copy</button>
<button type="button" id="a3cfg-download">Download</button>
</div>
</div>
<pre id="a3cfg-preview" class="a3cfg-pre"></pre>
</div>
</div>

<style>
  .a3cfg-tool {
    display: grid;
    gap: 1.25rem;
    margin-block: 1.5rem;
  }

  @media (min-width: 62rem) {
    .a3cfg-tool {
      grid-template-columns: minmax(0, 1.1fr) minmax(0, 1fr);
      align-items: start;
    }

    .a3cfg-output {
      position: sticky;
      top: 5rem;
    }
  }

  .a3cfg-form {
    display: grid;
    gap: 1rem;
    min-width: 0;
  }

  .a3cfg-fieldset {
    display: grid;
    gap: 0.75rem;
    border: 1px solid #262626;
    border-radius: 0.625rem;
    padding: 1rem;
    background: #0f0f0f;
  }

  .a3cfg-fieldset legend {
    padding-inline: 0.35rem;
    font-size: 0.8125rem;
    font-weight: 600;
    letter-spacing: 0.02em;
    text-transform: uppercase;
    color: #a3a3a3;
  }

  .a3cfg-field {
    display: grid;
    gap: 0.3rem;
    font-size: 0.9rem;
    color: #e5e5e5;
  }

  .a3cfg-field small {
    color: #737373;
    font-weight: 400;
  }

  .a3cfg-field-wide {
    grid-column: 1 / -1;
  }

  .a3cfg-field input[type='text'],
  .a3cfg-field input[type='number'],
  .a3cfg-field select,
  .a3cfg-field textarea {
    font: inherit;
    color: #f5f5f5;
    background: #141414;
    border: 1px solid #333333;
    border-radius: 0.5rem;
    padding: 0.5rem 0.65rem;
    width: 100%;
  }

  .a3cfg-field textarea {
    resize: vertical;
    font-family: inherit;
  }

  .a3cfg-field input:focus-visible,
  .a3cfg-field select:focus-visible,
  .a3cfg-field textarea:focus-visible {
    outline: 2px solid #525252;
    outline-offset: 1px;
  }

  .a3cfg-checkbox {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 0.5rem;
  }

  .a3cfg-checkbox input {
    width: 1rem;
    height: 1rem;
  }

  .a3cfg-output {
    display: grid;
    gap: 0.5rem;
    border: 1px solid #262626;
    border-radius: 0.625rem;
    background: #0c0c0c;
    overflow: hidden;
    align-self: start;
    min-width: 0;
  }

  .a3cfg-output-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 0.75rem;
    padding: 0.65rem 0.9rem;
    background: #141414;
    border-bottom: 1px solid #262626;
    font-size: 0.8125rem;
    font-weight: 600;
    color: #a3a3a3;
  }

  .a3cfg-actions {
    display: flex;
    gap: 0.5rem;
  }

  .a3cfg-actions button {
    font: inherit;
    font-size: 0.8125rem;
    color: #e5e5e5;
    background: #1a1a1a;
    border: 1px solid #333333;
    border-radius: 0.4rem;
    padding: 0.3rem 0.65rem;
    cursor: pointer;
  }

  .a3cfg-actions button:hover {
    border-color: #525252;
    color: #f5f5f5;
  }

  .a3cfg-pre {
    margin: 0;
    padding: 1rem;
    max-height: 34rem;
    overflow: auto;
    font-size: 0.8125rem;
    line-height: 1.5;
    white-space: pre-wrap;
    word-break: break-word;
  }
</style>

<script>
  (function () {
    const root = document.getElementById('a3cfg-tool')
    if (!root) return

    const byId = (id) => root.querySelector('#' + id)

    const escapeCfgString = (value) => String(value).replace(/\\/g, '\\\\').replace(/"/g, '\\"')

    const numberOrNull = (input) => {
      const raw = input.value.trim()
      if (raw === '') return null
      const n = Number(raw)
      return Number.isFinite(n) ? n : null
    }

    const build = () => {
      const lines = []
      const hostname = byId('a3cfg-hostname').value.trim() || 'Arma 3 Server'
      const password = byId('a3cfg-password').value
      const passwordAdmin = byId('a3cfg-passwordAdmin').value
      const serverCommandPassword = byId('a3cfg-serverCommandPassword').value
      const motdLines = byId('a3cfg-motd').value.split('\n').map((l) => l.trim()).filter(Boolean)
      const motdInterval = byId('a3cfg-motdInterval').value || '30'
      const maxPlayers = byId('a3cfg-maxPlayers').value || '32'
      const kickDuplicate = byId('a3cfg-kickDuplicate').checked ? 1 : 0
      const verifySignatures = byId('a3cfg-verifySignatures').value
      const allowedFilePatching = byId('a3cfg-allowedFilePatching').value
      const disconnectTimeout = byId('a3cfg-disconnectTimeout').value || '90'
      const maxDesync = numberOrNull(byId('a3cfg-maxDesync'))
      const maxPing = numberOrNull(byId('a3cfg-maxPing'))
      const maxPacketLoss = numberOrNull(byId('a3cfg-maxPacketLoss'))
      const battlEye = byId('a3cfg-battlEye').checked ? 1 : 0
      const persistent = byId('a3cfg-persistent').checked ? 1 : 0
      const disableVoN = byId('a3cfg-disableVoN').checked ? 1 : 0
      const vonCodec = byId('a3cfg-vonCodec').value
      const vonCodecQuality = byId('a3cfg-vonCodecQuality').value || '15'
      const voteThreshold = byId('a3cfg-voteThreshold').value || '0.33'
      const voteMissionPlayers = byId('a3cfg-voteMissionPlayers').value || '0'
      const logFile = byId('a3cfg-logFile').value.trim() || 'server_console.log'
      const timeStampFormat = byId('a3cfg-timeStampFormat').value

      lines.push(`hostname = "${escapeCfgString(hostname)}";`)
      if (password) lines.push(`password = "${escapeCfgString(password)}";`)
      if (passwordAdmin) lines.push(`passwordAdmin = "${escapeCfgString(passwordAdmin)}";`)
      if (serverCommandPassword) lines.push(`serverCommandPassword = "${escapeCfgString(serverCommandPassword)}";`)
      lines.push('')
      if (motdLines.length) {
        lines.push(`motd[] = {${motdLines.map((l) => `"${escapeCfgString(l)}"`).join(', ')}};`)
        lines.push(`motdInterval = ${motdInterval};`)
        lines.push('')
      }
      lines.push(`maxPlayers = ${maxPlayers};`)
      lines.push(`kickDuplicate = ${kickDuplicate};`)
      lines.push(`verifySignatures = ${verifySignatures};`)
      lines.push(`allowedFilePatching = ${allowedFilePatching};`)
      lines.push(`disconnectTimeout = ${disconnectTimeout};`)
      if (maxDesync !== null) lines.push(`maxDesync = ${maxDesync};`)
      if (maxPing !== null) lines.push(`maxPing = ${maxPing};`)
      if (maxPacketLoss !== null) lines.push(`maxPacketLoss = ${maxPacketLoss};`)
      lines.push('')
      lines.push(`BattlEye = ${battlEye};`)
      lines.push(`persistent = ${persistent};`)
      lines.push(`disableVoN = ${disableVoN};`)
      lines.push(`vonCodec = ${vonCodec};`)
      lines.push(`vonCodecQuality = ${vonCodecQuality};`)
      lines.push(`voteThreshold = ${voteThreshold};`)
      lines.push(`voteMissionPlayers = ${voteMissionPlayers};`)
      lines.push('')
      lines.push(`logFile = "${escapeCfgString(logFile)}";`)
      lines.push(`timeStampFormat = "${timeStampFormat}";`)

      return lines.join('\n') + '\n'
    }

    const preview = byId('a3cfg-preview')
    const render = () => {
      preview.textContent = build()
    }

    root.querySelectorAll('input, select, textarea').forEach((el) => {
      el.addEventListener('input', render)
      el.addEventListener('change', render)
    })

    const copyBtn = byId('a3cfg-copy')
    copyBtn.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(preview.textContent || '')
        copyBtn.textContent = 'Copied'
      } catch {
        copyBtn.textContent = 'Copy failed'
      }
      setTimeout(() => {
        copyBtn.textContent = 'Copy'
      }, 1500)
    })

    const downloadBtn = byId('a3cfg-download')
    downloadBtn.addEventListener('click', () => {
      const blob = new Blob([preview.textContent || ''], { type: 'text/plain' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = 'server.cfg'
      document.body.appendChild(a)
      a.click()
      a.remove()
      URL.revokeObjectURL(url)
    })

    render()
  })()
</script>

## Using the generated file

1. Copy or download the config from the preview panel.
2. Save it as dockerized/arma/arma-3/configs/server.cfg in your clone of this repo.
3. Start the server:

```bash
docker compose -f dockerized/arma/arma-3/docker-compose.yml up -d
```

CDLC, EXTRA_MODS, and workshop presets are set outside server.cfg. See the [Arma 3 guide](../servers/arma-3/) for mods and config path details.
