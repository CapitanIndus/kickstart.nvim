local home = os.getenv 'HOME'
local workspace_dir = home .. '/.local/share/eclipse/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

local config = {
  cmd = {
    'jdtls',
    '-data',
    workspace_dir,
  },

  root_dir = require('jdtls.setup').find_root { 'pom.xml', 'build.gradle', '.git' },

  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = 'JavaSE-21',
            path = '/usr/lib/jvm/java-21-openjdk-amd64', -- Debian/Ubuntu
          },
        },
      },
    },
  },

  init_options = {
    bundles = {},
  },
}

require('jdtls').start_or_attach(config)
