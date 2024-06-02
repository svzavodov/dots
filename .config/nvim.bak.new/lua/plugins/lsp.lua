local lspconfig = require("lspconfig")

lspconfig.tsserver.setup({
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = "/path/to/@vue/language-server",
        languages = { "vue" },
      },
    },
  },

  lspconfig.volar.setup({
    init_options = {
      vue = {
        hybridMode = false,
      },
    },
  }),
})
