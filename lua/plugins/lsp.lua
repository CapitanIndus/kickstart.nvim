return {
  -- Zentrale LSP-Konfiguration fuer Neovim.
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Mason installiert externe Tools/LSP-Server.
    { 'mason-org/mason.nvim', opts = {} },
    -- Verbindet Mason mit nvim-lspconfig.
    'mason-org/mason-lspconfig.nvim',
    -- Installiert die in `ensure_installed` definierten Tools automatisch.
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    -- Zeigt LSP-Fortschritt dezent in der UI an.
    { 'j-hui/fidget.nvim', opts = {} },
    -- Liefert Completion-Capabilities fuer die LSP-Clients.
    'saghen/blink.cmp',
  },
  config = function()
    -- Pfad zur von Mason installierten Biome-Binary.
    local mason_biome = vim.fn.stdpath 'data' .. '/mason/bin/biome'
    local fs = vim.fs
    local uv = vim.uv
    local mason_packages = vim.fn.stdpath 'data' .. '/mason/packages'
    local mason_angular_node_modules = fs.joinpath(mason_packages, 'angular-language-server', 'node_modules')

    local function add_existing_path(paths, path)
      if not path or path == '' then
        return
      end

      path = fs.normalize(path)
      if not uv.fs_stat(path) then
        return
      end

      for _, existing in ipairs(paths) do
        if existing == path then
          return
        end
      end

      table.insert(paths, path)
    end

    local function collect_angular_node_modules(root_dir)
      local paths = {}

      if root_dir and root_dir ~= '' then
        add_existing_path(paths, fs.find('node_modules', { path = root_dir, upward = true, type = 'directory' })[1])
      end

      add_existing_path(paths, mason_angular_node_modules)

      local ngserver_exe = vim.fn.exepath 'ngserver'
      if ngserver_exe and ngserver_exe ~= '' then
        local realpath = uv.fs_realpath(ngserver_exe) or ngserver_exe
        add_existing_path(paths, fs.joinpath(fs.dirname(realpath), '../../node_modules'))
      end

      return paths
    end

    local function get_angular_core_version(root_dir)
      if not root_dir or root_dir == '' then
        return ''
      end

      local package_json = fs.find('package.json', { path = root_dir, upward = true, type = 'file' })[1]
      if not package_json then
        return ''
      end

      local ok, file = pcall(io.open, package_json, 'r')
      if not ok or not file then
        return ''
      end

      local contents = file:read '*a'
      file:close()

      local decode_ok, json = pcall(vim.json.decode, contents)
      if not decode_ok or type(json) ~= 'table' then
        return ''
      end

      local dependencies = vim.tbl_extend('force', json.dependencies or {}, json.devDependencies or {})
      local version = dependencies['@angular/core']
      return version and version:match '%d+%.%d+%.%d+' or ''
    end

    -- Dieser Autocmd laeuft immer dann, wenn ein LSP-Client an einen Buffer gebunden wird.
    -- So bleiben Keymaps und Zusatzfunktionen buffer-lokal und werden nur bei Bedarf gesetzt.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- Kleine Hilfsfunktion, damit alle LSP-Keymaps denselben Stil haben.
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Standard-LSP-Aktionen: umbenennen, Code Actions und Navigation.
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
        map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
        map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
        map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

        -- API-Kompatibilitaet zwischen Neovim 0.10 und 0.11:
        -- `supports_method` bekam in 0.11 eine leicht andere Signatur.
        local function client_supports_method(client, method, bufnr)
          if vim.fn.has 'nvim-0.11' == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          -- Hebt alle Referenzen des Symbols unter dem Cursor hervor,
          -- solange der Server diese LSP-Methode unterstuetzt.
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          -- Raeumt die Highlight-Autocmds wieder auf, wenn der LSP-Client getrennt wird.
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          -- Inlay Hints sind kleine eingeblendete Zusatzinfos wie Typen oder Parameternamen.
          -- Der Toggle wird nur gesetzt, wenn der aktuelle Server dieses Feature wirklich kann.
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- Globale Darstellung von Diagnosen/Fehlern aus allen LSP-Servern.
    vim.diagnostic.config {
      -- Hoehere Schweregrade werden bevorzugt sortiert/angezeigt.
      severity_sort = true,
      -- Floating-Fenster mit rundem Rand; `source = if_many` zeigt die Quelle nur,
      -- wenn mehrere Diagnosequellen beteiligt sind.
      float = { border = 'rounded', source = 'if_many' },
      -- Unterstreichung nur fuer echte Fehler, damit Warnungen optisch ruhiger bleiben.
      underline = { severity = vim.diagnostic.severity.ERROR },
      -- Nur Nerd-Font-Icons verwenden, wenn sie im Setup verfuegbar sind.
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      -- Virtueller Text direkt im Buffer; hier wird momentan nur die eigentliche Nachricht gezeigt.
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }

    -- Completion-Features aus blink.cmp an alle LSP-Server weiterreichen.
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Alle hier eingetragenen Server werden spaeter konfiguriert und aktiviert.
    local servers = {
      angularls = {
        cmd = function(dispatchers, config)
          local root_dir = (config or {}).root_dir or (config or {}).root or vim.fn.getcwd()
          local node_modules = collect_angular_node_modules(root_dir)
          local ng_probe_locations = {}

          for _, node_modules_path in ipairs(node_modules) do
            add_existing_path(ng_probe_locations, node_modules_path)
            add_existing_path(ng_probe_locations, fs.joinpath(node_modules_path, '@angular/language-server/node_modules'))
          end

          local ngserver = vim.fn.exepath 'ngserver'
          if not ngserver or ngserver == '' then
            ngserver = 'ngserver'
          end

          return vim.lsp.rpc.start({
            ngserver,
            '--stdio',
            '--tsProbeLocations',
            table.concat(node_modules, ','),
            '--ngProbeLocations',
            table.concat(ng_probe_locations, ','),
            '--angularCoreVersion',
            get_angular_core_version(root_dir),
          }, dispatchers)
        end,
        filetypes = { 'typescript', 'html', 'typescriptreact', 'typescript.tsx', 'htmlangular' },
        root_markers = { 'angular.json', 'nx.json' },
      },
      biome = {
        -- Bevorzugt die projektlokale Biome-Version, faellt sonst auf globale oder Mason-Version zurueck.
        cmd = function(dispatchers, config)
          local cmd = mason_biome
          local local_cmd = (config or {}).root_dir and config.root_dir .. '/node_modules/.bin/biome'

          if local_cmd and vim.fn.executable(local_cmd) == 1 then
            cmd = local_cmd
          elseif vim.fn.executable 'biome' == 1 then
            cmd = 'biome'
          end

          return vim.lsp.rpc.start({ cmd, 'lsp-proxy' }, dispatchers)
        end,
        -- Sucht das Projektwurzelverzeichnis anhand typischer JS/TS/Biome-Dateien.
        root_dir = function(bufnr, on_dir)
          local root_markers = {
            'biome.json',
            'biome.jsonc',
            'package.json',
            'package-lock.json',
            'yarn.lock',
            'pnpm-lock.yaml',
            'bun.lockb',
            'bun.lock',
            '.git',
          }
          local filename = vim.api.nvim_buf_get_name(bufnr)
          local root = vim.fs.root(bufnr, root_markers) or vim.fs.dirname(filename) or vim.fn.getcwd()
          on_dir(root)
        end,
        -- Biome darf auch auf Einzeldateien ohne klares Projektverzeichnis laufen.
        single_file_support = true,
      },
      cssls = {},
      superhtml = {},
      ts_ls = {},
      pylsp = {},
      lua_ls = {
        settings = {
          Lua = {
            -- Ersetzt existierenden Text direkt beim Einfuegen von Snippets aus der Completion.
            completion = { callSnippet = 'Replace' },
          },
        },
      },
      intelephense = {
        settings = {
          intelephense = {
            environment = {
              phpVersion = '8.4', -- damit du volle PHP 8.4-Unterstützung bekommst
            },
            files = {
              maxSize = 5000000,
            },
          },
        },
      },
    }

    -- Alle definierten Server plus zusaetzliche Tools wie Stylua automatisch installieren.
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, { 'stylua' })

    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- Mason installiert nur; aktiviert wird spaeter bewusst manuell pro Server.
    require('mason-lspconfig').setup {
      ensure_installed = {},
      automatic_enable = false,
    }

    -- Gleiche Basis-Capabilities an jeden Server haengen und danach explizit aktivieren.
    for server_name, server in pairs(servers) do
      if server_name ~= 'rust_analyzer' then
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(server_name, server)
        vim.lsp.enable(server_name)
      end
    end
  end,
}
