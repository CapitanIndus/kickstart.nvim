local home = os.getenv 'HOME'
local workspace_dir = home .. '/.local/share/eclipse/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local lombok_jar = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'packages', 'jdtls', 'lombok.jar')

local cmd = {
  'jdtls',
  '-data',
  workspace_dir,
}

if vim.fn.filereadable(lombok_jar) == 1 then
  -- Lombok muss bereits in der JVM von jdtls als Java-Agent geladen werden.
  table.insert(cmd, 2, '--jvm-arg=-javaagent:' .. lombok_jar)
else
  vim.notify('jdtls: Lombok-Agent nicht gefunden: ' .. lombok_jar, vim.log.levels.WARN)
end

local config = {
  cmd = cmd,

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
