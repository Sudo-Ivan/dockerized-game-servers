---
title: Minecraft server.properties Generator
description: Build a server.properties for the Minecraft dedicated server images in your browser.
---

Fill in the fields below to build a `server.properties` for the [Minecraft images](../servers/minecraft/) (Fabric, Vanilla, Forge, NeoForge). The output updates as you type.

:::note[Client-side only]
Nothing here is uploaded. The file is generated with JavaScript in your browser.
:::

<div id="mcprops-tool" class="mcprops-tool" data-tool>
  <form id="mcprops-form" class="mcprops-form">
    <fieldset class="mcprops-fieldset">
      <legend>World</legend>

      <label class="mcprops-field">
        <span>Level name</span>
        <input type="text" id="mcprops-level-name" value="world" />
      </label>

      <label class="mcprops-field">
        <span>Level seed <small>(blank = random)</small></span>
        <input type="text" id="mcprops-level-seed" value="" />
      </label>

      <label class="mcprops-field">
        <span>Level type</span>
        <select id="mcprops-level-type">
          <option value="minecraft:normal" selected>Normal</option>
          <option value="minecraft:flat">Flat</option>
          <option value="minecraft:large_biomes">Large biomes</option>
          <option value="minecraft:amplified">Amplified</option>
        </select>
      </label>

      <label class="mcprops-field">
        <span>Gamemode</span>
        <select id="mcprops-gamemode">
          <option value="survival" selected>Survival</option>
          <option value="creative">Creative</option>
          <option value="adventure">Adventure</option>
          <option value="spectator">Spectator</option>
        </select>
      </label>

      <label class="mcprops-field">
        <span>Difficulty</span>
        <select id="mcprops-difficulty">
          <option value="peaceful">Peaceful</option>
          <option value="easy">Easy</option>
          <option value="normal" selected>Normal</option>
          <option value="hard">Hard</option>
        </select>
      </label>

      <label class="mcprops-field a3cfg-checkbox mcprops-checkbox">
        <input type="checkbox" id="mcprops-hardcore" />
        <span>Hardcore</span>
      </label>
    </fieldset>

    <fieldset class="mcprops-fieldset">
      <legend>Players and access</legend>

      <label class="mcprops-field">
        <span>Server port</span>
        <input type="number" id="mcprops-server-port" value="25565" min="1" max="65535" />
      </label>

      <label class="mcprops-field">
        <span>Max players</span>
        <input type="number" id="mcprops-max-players" value="20" min="1" max="2000" />
      </label>

      <label class="mcprops-field mcprops-checkbox">
        <input type="checkbox" id="mcprops-online-mode" checked />
        <span>Online mode (Mojang authentication)</span>
      </label>

      <label class="mcprops-field mcprops-checkbox">
        <input type="checkbox" id="mcprops-white-list" />
        <span>Enable whitelist</span>
      </label>

      <label class="mcprops-field mcprops-checkbox">
        <input type="checkbox" id="mcprops-pvp" checked />
        <span>PvP</span>
      </label>

      <label class="mcprops-field mcprops-checkbox">
        <input type="checkbox" id="mcprops-allow-flight" />
        <span>Allow flight</span>
      </label>

      <label class="mcprops-field mcprops-checkbox">
        <input type="checkbox" id="mcprops-enable-command-block" />
        <span>Enable command blocks</span>
      </label>
    </fieldset>

    <fieldset class="mcprops-fieldset">
      <legend>Performance and view</legend>

      <label class="mcprops-field">
        <span>View distance <small>(chunks)</small></span>
        <input type="number" id="mcprops-view-distance" value="10" min="3" max="32" />
      </label>

      <label class="mcprops-field">
        <span>Simulation distance <small>(chunks)</small></span>
        <input type="number" id="mcprops-simulation-distance" value="10" min="3" max="32" />
      </label>

      <label class="mcprops-field">
        <span>Spawn protection radius</span>
        <input type="number" id="mcprops-spawn-protection" value="16" min="0" />
      </label>
    </fieldset>

    <fieldset class="mcprops-fieldset">
      <legend>Motd and RCON</legend>

      <label class="mcprops-field a3cfg-field-wide">
        <span>MOTD</span>
        <input type="text" id="mcprops-motd" value="A Minecraft Server" maxlength="59" />
      </label>

      <label class="mcprops-field mcprops-checkbox">
        <input type="checkbox" id="mcprops-enable-rcon" />
        <span>Enable RCON</span>
      </label>

      <label class="mcprops-field">
        <span>RCON port</span>
        <input type="number" id="mcprops-rcon-port" value="25575" min="1" max="65535" />
      </label>

      <label class="mcprops-field">
        <span>RCON password <small>(required if RCON enabled)</small></span>
        <input type="text" id="mcprops-rcon-password" value="" />
      </label>
    </fieldset>
  </form>

  <div class="mcprops-output">
    <div class="mcprops-output-head">
      <span>server.properties</span>
      <div class="mcprops-actions">
        <button type="button" id="mcprops-copy">Copy</button>
        <button type="button" id="mcprops-download">Download</button>
      </div>
    </div>
    <pre id="mcprops-preview" class="mcprops-pre"></pre>
  </div>
</div>

<style>
  .mcprops-tool {
    display: grid;
    gap: 1.25rem;
    margin-block: 1.5rem;
  }

  @media (min-width: 62rem) {
    .mcprops-tool {
      grid-template-columns: 1.1fr 1fr;
      align-items: start;
    }
  }

  .mcprops-form {
    display: grid;
    gap: 1rem;
  }

  .mcprops-fieldset {
    display: grid;
    gap: 0.75rem;
    border: 1px solid #262626;
    border-radius: 0.625rem;
    padding: 1rem;
    background: #0f0f0f;
  }

  .mcprops-fieldset legend {
    padding-inline: 0.35rem;
    font-size: 0.8125rem;
    font-weight: 600;
    letter-spacing: 0.02em;
    text-transform: uppercase;
    color: #a3a3a3;
  }

  .mcprops-field {
    display: grid;
    gap: 0.3rem;
    font-size: 0.9rem;
    color: #e5e5e5;
  }

  .mcprops-field small {
    color: #737373;
    font-weight: 400;
  }

  .mcprops-field input[type='text'],
  .mcprops-field input[type='number'],
  .mcprops-field select {
    font: inherit;
    color: #f5f5f5;
    background: #141414;
    border: 1px solid #333333;
    border-radius: 0.5rem;
    padding: 0.5rem 0.65rem;
    width: 100%;
  }

  .mcprops-field input:focus-visible,
  .mcprops-field select:focus-visible {
    outline: 2px solid #525252;
    outline-offset: 1px;
  }

  .mcprops-checkbox {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 0.5rem;
  }

  .mcprops-checkbox input {
    width: 1rem;
    height: 1rem;
  }

  .mcprops-output {
    position: sticky;
    top: 5rem;
    display: grid;
    gap: 0.5rem;
    border: 1px solid #262626;
    border-radius: 0.625rem;
    background: #0c0c0c;
    overflow: hidden;
    align-self: start;
  }

  .mcprops-output-head {
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

  .mcprops-actions {
    display: flex;
    gap: 0.5rem;
  }

  .mcprops-actions button {
    font: inherit;
    font-size: 0.8125rem;
    color: #e5e5e5;
    background: #1a1a1a;
    border: 1px solid #333333;
    border-radius: 0.4rem;
    padding: 0.3rem 0.65rem;
    cursor: pointer;
  }

  .mcprops-actions button:hover {
    border-color: #525252;
    color: #f5f5f5;
  }

  .mcprops-pre {
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
    const root = document.getElementById('mcprops-tool')
    if (!root) return

    const byId = (id) => root.querySelector('#' + id)
    const bool = (id) => (byId(id).checked ? 'true' : 'false')
    const val = (id) => byId(id).value

    const build = () => {
      const rconPassword = val('mcprops-rcon-password')
      const enableRcon = byId('mcprops-enable-rcon').checked

      const entries = [
        ['level-name', val('mcprops-level-name').trim() || 'world'],
        ['level-seed', val('mcprops-level-seed')],
        ['level-type', val('mcprops-level-type')],
        ['gamemode', val('mcprops-gamemode')],
        ['difficulty', val('mcprops-difficulty')],
        ['hardcore', bool('mcprops-hardcore')],
        ['server-port', val('mcprops-server-port') || '25565'],
        ['max-players', val('mcprops-max-players') || '20'],
        ['online-mode', bool('mcprops-online-mode')],
        ['white-list', bool('mcprops-white-list')],
        ['pvp', bool('mcprops-pvp')],
        ['allow-flight', bool('mcprops-allow-flight')],
        ['enable-command-block', bool('mcprops-enable-command-block')],
        ['view-distance', val('mcprops-view-distance') || '10'],
        ['simulation-distance', val('mcprops-simulation-distance') || '10'],
        ['spawn-protection', val('mcprops-spawn-protection') || '16'],
        ['motd', val('mcprops-motd')],
        ['enable-rcon', enableRcon ? 'true' : 'false'],
        ['rcon.port', val('mcprops-rcon-port') || '25575'],
        ['rcon.password', enableRcon ? rconPassword : ''],
      ]

      return entries.map(([key, value]) => `${key}=${value}`).join('\n') + '\n'
    }

    const preview = byId('mcprops-preview')
    const render = () => {
      preview.textContent = build()
    }

    root.querySelectorAll('input, select').forEach((el) => {
      el.addEventListener('input', render)
      el.addEventListener('change', render)
    })

    const copyBtn = byId('mcprops-copy')
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

    const downloadBtn = byId('mcprops-download')
    downloadBtn.addEventListener('click', () => {
      const blob = new Blob([preview.textContent || ''], { type: 'text/plain' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = 'server.properties'
      document.body.appendChild(a)
      a.click()
      a.remove()
      URL.revokeObjectURL(url)
    })

    render()
  })()
</script>

## Using the generated file

1. Copy or download the output above.
2. Save it as `server.properties` under the flavor's data volume, for example `minecraft/vanilla/data/server.properties`.
3. Restart the container. Most `server.properties` changes only apply on restart.

Set `EULA=true` when starting the container. See the [Minecraft guide](../servers/minecraft/) for volumes, mods, and datapacks.
