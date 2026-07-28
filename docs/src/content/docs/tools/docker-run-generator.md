---
title: Docker Run / Compose Generator
description: Build a docker run command or docker-compose.yml snippet for any game server image.
---

Build a `docker run` command or a `docker-compose.yml` service from an image name, ports, volumes, and environment variables. Works with any image, not only the ones in this repository.

:::note[Client-side only]
Nothing here is uploaded. The output is generated with JavaScript in your browser.
:::

<div id="drun-tool" class="drun-tool" data-tool>
<form id="drun-form" class="drun-form">
<fieldset class="drun-fieldset">
<legend>Container</legend>

<label class="drun-field">
<span>Image</span>
<input type="text" id="drun-image" value="ghcr.io/example/minecraft-vanilla:latest" />
</label>

<label class="drun-field">
<span>Container name</span>
<input type="text" id="drun-name" value="my-server" />
</label>

<label class="drun-field">
<span>Restart policy</span>
<select id="drun-restart">
<option value="">None</option>
<option value="unless-stopped" selected>Unless stopped</option>
<option value="always">Always</option>
<option value="on-failure">On failure</option>
</select>
</label>

<label class="drun-field drun-checkbox">
<input type="checkbox" id="drun-init" checked />
<span>Run with an init process (<code>--init</code>)</span>
</label>
</fieldset>

<fieldset class="drun-fieldset">
<legend>Ports</legend>
<div id="drun-ports" class="drun-rows"></div>
<button type="button" id="drun-add-port" class="drun-add">Add port</button>
</fieldset>

<fieldset class="drun-fieldset">
<legend>Volumes</legend>
<div id="drun-volumes" class="drun-rows"></div>
<button type="button" id="drun-add-volume" class="drun-add">Add volume</button>
</fieldset>

<fieldset class="drun-fieldset">
<legend>Environment variables</legend>
<div id="drun-envs" class="drun-rows"></div>
<button type="button" id="drun-add-env" class="drun-add">Add variable</button>
</fieldset>
</form>

<div class="drun-output">
<div class="drun-output-head">
<span id="drun-output-label">docker run</span>
<div class="drun-tabs">
<button type="button" id="drun-tab-run" class="drun-tab is-active" data-tab="run">docker run</button>
<button type="button" id="drun-tab-compose" class="drun-tab" data-tab="compose">compose</button>
</div>
<div class="drun-actions">
<button type="button" id="drun-copy">Copy</button>
<button type="button" id="drun-download">Download</button>
</div>
</div>
<pre id="drun-preview" class="drun-pre"></pre>
</div>
</div>

<template id="drun-port-row-template">
<div class="drun-row" data-row>
<input type="text" class="drun-host-port" placeholder="Host port" value="" />
<span class="drun-sep">:</span>
<input type="text" class="drun-container-port" placeholder="Container port" value="" />
<select class="drun-proto">
<option value="tcp">tcp</option>
<option value="udp">udp</option>
<option value="both">tcp+udp</option>
</select>
<button type="button" class="drun-remove" data-remove aria-label="Remove port">Remove</button>
</div>
</template>

<template id="drun-volume-row-template">
<div class="drun-row" data-row>
<input type="text" class="drun-host-path" placeholder="Host path" value="" />
<span class="drun-sep">:</span>
<input type="text" class="drun-container-path" placeholder="Container path" value="" />
<button type="button" class="drun-remove" data-remove aria-label="Remove volume">Remove</button>
</div>
</template>

<template id="drun-env-row-template">
<div class="drun-row" data-row>
<input type="text" class="drun-env-key" placeholder="KEY" value="" />
<span class="drun-sep">=</span>
<input type="text" class="drun-env-value" placeholder="value" value="" />
<button type="button" class="drun-remove" data-remove aria-label="Remove variable">Remove</button>
</div>
</template>

<style>
  .drun-tool {
    display: grid;
    gap: 1.25rem;
    margin-block: 1.5rem;
  }

  @media (min-width: 62rem) {
    .drun-tool {
      grid-template-columns: minmax(0, 1.1fr) minmax(0, 1fr);
      align-items: start;
    }

    .drun-output {
      position: sticky;
      top: 5rem;
    }
  }

  .drun-form {
    display: grid;
    gap: 1rem;
    min-width: 0;
  }

  .drun-fieldset {
    display: grid;
    gap: 0.75rem;
    border: 1px solid #262626;
    border-radius: 0.625rem;
    padding: 1rem;
    background: #0f0f0f;
  }

  .drun-fieldset legend {
    padding-inline: 0.35rem;
    font-size: 0.8125rem;
    font-weight: 600;
    letter-spacing: 0.02em;
    text-transform: uppercase;
    color: #a3a3a3;
  }

  .drun-field {
    display: grid;
    gap: 0.3rem;
    font-size: 0.9rem;
    color: #e5e5e5;
  }

  .drun-field input[type='text'],
  .drun-field select {
    font: inherit;
    color: #f5f5f5;
    background: #141414;
    border: 1px solid #333333;
    border-radius: 0.5rem;
    padding: 0.5rem 0.65rem;
    width: 100%;
  }

  .drun-field input:focus-visible,
  .drun-field select:focus-visible {
    outline: 2px solid #525252;
    outline-offset: 1px;
  }

  .drun-checkbox {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 0.5rem;
  }

  .drun-checkbox input {
    width: 1rem;
    height: 1rem;
  }

  .drun-rows {
    display: grid;
    gap: 0.5rem;
  }

  .drun-row {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr) auto auto;
    align-items: center;
    gap: 0.4rem;
    min-width: 0;
  }

  .drun-row:has(.drun-env-key),
  .drun-row:has(.drun-host-path) {
    grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr) auto;
  }

  @media (max-width: 34rem) {
    .drun-row,
    .drun-row:has(.drun-env-key),
    .drun-row:has(.drun-host-path) {
      grid-template-columns: 1fr;
    }

    .drun-sep {
      display: none;
    }

    .drun-remove {
      justify-self: start;
    }
  }

  .drun-row input,
  .drun-row select {
    font: inherit;
    font-size: 0.85rem;
    color: #f5f5f5;
    background: #141414;
    border: 1px solid #333333;
    border-radius: 0.4rem;
    padding: 0.4rem 0.5rem;
    min-width: 0;
    width: 100%;
  }

  .drun-sep {
    color: #737373;
  }

  .drun-remove {
    font: inherit;
    font-size: 0.75rem;
    color: #c4c4c4;
    background: #1a1a1a;
    border: 1px solid #333333;
    border-radius: 0.4rem;
    padding: 0.35rem 0.55rem;
    cursor: pointer;
  }

  .drun-remove:hover {
    border-color: #6b4545;
    color: #e8c8c8;
  }

  .drun-add {
    justify-self: start;
    font: inherit;
    font-size: 0.8125rem;
    color: #e5e5e5;
    background: #1a1a1a;
    border: 1px solid #333333;
    border-radius: 0.4rem;
    padding: 0.35rem 0.7rem;
    cursor: pointer;
  }

  .drun-add:hover {
    border-color: #525252;
    color: #f5f5f5;
  }

  .drun-output {
    display: grid;
    gap: 0.5rem;
    border: 1px solid #262626;
    border-radius: 0.625rem;
    background: #0c0c0c;
    overflow: hidden;
    align-self: start;
    min-width: 0;
  }

  .drun-output-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 0.75rem;
    flex-wrap: wrap;
    padding: 0.65rem 0.9rem;
    background: #141414;
    border-bottom: 1px solid #262626;
    font-size: 0.8125rem;
    font-weight: 600;
    color: #a3a3a3;
  }

  .drun-tabs {
    display: flex;
    gap: 0.35rem;
  }

  .drun-tab {
    font: inherit;
    font-size: 0.75rem;
    color: #a3a3a3;
    background: transparent;
    border: 1px solid #333333;
    border-radius: 999px;
    padding: 0.25rem 0.65rem;
    cursor: pointer;
  }

  .drun-tab.is-active {
    color: #0a0a0a;
    background: #d4d4d4;
    border-color: #d4d4d4;
  }

  .drun-actions {
    display: flex;
    gap: 0.5rem;
  }

  .drun-actions button {
    font: inherit;
    font-size: 0.8125rem;
    color: #e5e5e5;
    background: #1a1a1a;
    border: 1px solid #333333;
    border-radius: 0.4rem;
    padding: 0.3rem 0.65rem;
    cursor: pointer;
  }

  .drun-actions button:hover {
    border-color: #525252;
    color: #f5f5f5;
  }

  .drun-pre {
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
    const root = document.getElementById('drun-tool')
    if (!root) return

    const byId = (id) => root.querySelector('#' + id)

    let activeTab = 'run'

    const addRow = (containerId, templateId, focus) => {
      const container = byId(containerId)
      const template = document.getElementById(templateId)
      if (!(template instanceof HTMLTemplateElement)) return
      const node = template.content.firstElementChild.cloneNode(true)
      container.appendChild(node)
      node.querySelectorAll('input, select').forEach((el) => {
        el.addEventListener('input', render)
        el.addEventListener('change', render)
      })
      const removeBtn = node.querySelector('[data-remove]')
      removeBtn.addEventListener('click', () => {
        node.remove()
        render()
      })
      if (focus) {
        const firstInput = node.querySelector('input')
        if (firstInput) firstInput.focus()
      }
      return node
    }

    const shellQuote = (value) => {
      if (value === '') return "''"
      if (/^[A-Za-z0-9_.\-\/:@]+$/.test(value)) return value
      return `'${value.replace(/'/g, `'\\''`)}'`
    }

    const yamlScalar = (value) => {
      if (value === '') return '""'
      if (/^[A-Za-z0-9_.\-]+$/.test(value)) return value
      return `"${value.replace(/\\/g, '\\\\').replace(/"/g, '\\"')}"`
    }

    const collectPorts = () => {
      return [...byId('drun-ports').querySelectorAll('[data-row]')]
        .map((row) => {
          const hostPort = row.querySelector('.drun-host-port').value.trim()
          const containerPort = row.querySelector('.drun-container-port').value.trim()
          const proto = row.querySelector('.drun-proto').value
          return { hostPort, containerPort, proto }
        })
        .filter((p) => p.hostPort && p.containerPort)
    }

    const collectVolumes = () => {
      return [...byId('drun-volumes').querySelectorAll('[data-row]')]
        .map((row) => {
          const hostPath = row.querySelector('.drun-host-path').value.trim()
          const containerPath = row.querySelector('.drun-container-path').value.trim()
          return { hostPath, containerPath }
        })
        .filter((v) => v.hostPath && v.containerPath)
    }

    const collectEnvs = () => {
      return [...byId('drun-envs').querySelectorAll('[data-row]')]
        .map((row) => {
          const key = row.querySelector('.drun-env-key').value.trim()
          const value = row.querySelector('.drun-env-value').value
          return { key, value }
        })
        .filter((e) => e.key)
    }

    const buildRunCommand = () => {
      const image = byId('drun-image').value.trim() || 'image:latest'
      const name = byId('drun-name').value.trim() || 'server'
      const restart = byId('drun-restart').value
      const useInit = byId('drun-init').checked
      const ports = collectPorts()
      const volumes = collectVolumes()
      const envs = collectEnvs()

      const parts = ['docker run -d', `--name ${shellQuote(name)}`]
      if (restart) parts.push(`--restart ${restart}`)
      if (useInit) parts.push('--init')

      for (const p of ports) {
        if (p.proto === 'both') {
          parts.push(`-p ${p.hostPort}:${p.containerPort}/tcp`)
          parts.push(`-p ${p.hostPort}:${p.containerPort}/udp`)
        } else {
          parts.push(`-p ${p.hostPort}:${p.containerPort}/${p.proto}`)
        }
      }

      for (const v of volumes) {
        parts.push(`-v ${shellQuote(v.hostPath)}:${shellQuote(v.containerPath)}`)
      }

      for (const e of envs) {
        parts.push(`-e ${e.key}=${shellQuote(e.value)}`)
      }

      parts.push(shellQuote(image))

      return parts.join(' \\\n  ') + '\n'
    }

    const buildCompose = () => {
      const image = byId('drun-image').value.trim() || 'image:latest'
      const name = byId('drun-name').value.trim() || 'server'
      const restart = byId('drun-restart').value
      const useInit = byId('drun-init').checked
      const ports = collectPorts()
      const volumes = collectVolumes()
      const envs = collectEnvs()

      const lines = ['services:', `  ${name}:`, `    image: ${yamlScalar(image)}`, `    container_name: ${yamlScalar(name)}`]
      if (restart) lines.push(`    restart: ${restart}`)
      if (useInit) lines.push('    init: true')

      if (ports.length) {
        lines.push('    ports:')
        for (const p of ports) {
          if (p.proto === 'both') {
            lines.push(`      - "${p.hostPort}:${p.containerPort}/tcp"`)
            lines.push(`      - "${p.hostPort}:${p.containerPort}/udp"`)
          } else {
            lines.push(`      - "${p.hostPort}:${p.containerPort}/${p.proto}"`)
          }
        }
      }

      if (volumes.length) {
        lines.push('    volumes:')
        for (const v of volumes) {
          lines.push(`      - ${yamlScalar(v.hostPath)}:${yamlScalar(v.containerPath)}`)
        }
      }

      if (envs.length) {
        lines.push('    environment:')
        for (const e of envs) {
          lines.push(`      ${e.key}: ${yamlScalar(e.value)}`)
        }
      }

      return lines.join('\n') + '\n'
    }

    const preview = byId('drun-preview')
    const label = byId('drun-output-label')

    function render() {
      if (activeTab === 'run') {
        preview.textContent = buildRunCommand()
        label.textContent = 'docker run'
      } else {
        preview.textContent = buildCompose()
        label.textContent = 'docker-compose.yml'
      }
    }

    root.querySelectorAll('#drun-form input, #drun-form select').forEach((el) => {
      el.addEventListener('input', render)
      el.addEventListener('change', render)
    })

    root.querySelectorAll('.drun-tab').forEach((tab) => {
      tab.addEventListener('click', () => {
        activeTab = tab.dataset.tab
        root.querySelectorAll('.drun-tab').forEach((t) => t.classList.toggle('is-active', t === tab))
        render()
      })
    })

    byId('drun-add-port').addEventListener('click', () => addRow('drun-ports', 'drun-port-row-template', true))
    byId('drun-add-volume').addEventListener('click', () => addRow('drun-volumes', 'drun-volume-row-template', true))
    byId('drun-add-env').addEventListener('click', () => addRow('drun-envs', 'drun-env-row-template', true))

    const copyBtn = byId('drun-copy')
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

    const downloadBtn = byId('drun-download')
    downloadBtn.addEventListener('click', () => {
      const isCompose = activeTab === 'compose'
      const blob = new Blob([preview.textContent || ''], { type: 'text/plain' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = isCompose ? 'docker-compose.yml' : 'run.sh'
      document.body.appendChild(a)
      a.click()
      a.remove()
      URL.revokeObjectURL(url)
    })

    const port1 = addRow('drun-ports', 'drun-port-row-template', false)
    if (port1) {
      port1.querySelector('.drun-host-port').value = '25565'
      port1.querySelector('.drun-container-port').value = '25565'
      port1.querySelector('.drun-proto').value = 'both'
    }

    const volume1 = addRow('drun-volumes', 'drun-volume-row-template', false)
    if (volume1) {
      volume1.querySelector('.drun-host-path').value = './data'
      volume1.querySelector('.drun-container-path').value = '/data'
    }

    const env1 = addRow('drun-envs', 'drun-env-row-template', false)
    if (env1) {
      env1.querySelector('.drun-env-key').value = 'EULA'
      env1.querySelector('.drun-env-value').value = 'true'
    }

    render()
  })()
</script>

## Notes

- The generated `docker run` command escapes values for a POSIX shell. Review it before running with untrusted input.
- Ports set to `tcp+udp` expand into two `-p` flags or two `ports:` entries.
- This tool has no knowledge of a specific image's required ports or volumes. Check the [server list](../reference/servers/) for a link to each server's own guide.
