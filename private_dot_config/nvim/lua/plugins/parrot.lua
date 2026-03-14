local prefix = "<leader>ap"
return {
  {
    "frankroeder/parrot.nvim",
    dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
    -- optionally include "rcarriga/nvim-notify" for beautiful notifications
    keys = {
      { prefix .. "c", "<cmd>PrtChatToggle<cr>", desc = "Open Parrot Chat" },
      { prefix .. "r", "<cmd>PrtChatRespond<cr>", desc = "Respond to Parrot Chat" },
      { prefix .. "s", "<cmd>PrtChatStop<cr>", desc = "Interrupt ongoing Parrot respond" },
      { prefix .. "d", "<cmd>PrtChatDelete<cr>", desc = "Delete the current chat file" },
      { prefix .. "p", "<cmd>PrtProvider<cr>", desc = "Change the current Provider" },
      { prefix .. "m", "<cmd>PrtModel<cr>", desc = "Change the current Model" },
      { prefix .. "a", ":PrtAppend ", desc = "Use Parrot to append code", mode = { "v" } },
      { prefix .. "r", ":PrtRewrite ", desc = "Use Parrot to rewrite code", mode = { "v" } },
      { prefix .. "p", ":PrtPrepend", desc = "Use Parrot to prepend code", mode = { "v" } },
      {
        prefix .. "d",
        ":PrtPrepend write docs for this function or type<cr>",
        desc = "🦜 Use Parrot to write docs for function or type",
        mode = { "v" },
      },
    },
    config = function()
      require("parrot").setup({
        -- Providers must be explicitly added to make them available.
        providers = {
          anthropic = {
            name = "anthropic",
            endpoint = "https://api.anthropic.com/v1/messages",
            model_endpoint = "https://api.anthropic.com/v1/models",
            api_key = os.getenv("ANTHROPIC_API_KEY"),
            params = {
              chat = { max_tokens = 4096 },
              command = { max_tokens = 4096 },
            },
            topic = {
              model = "claude-haiku-4-5-20251001",
              params = { max_tokens = 64 },
            },
            headers = function(self)
              return {
                ["Content-Type"] = "application/json",
                ["x-api-key"] = self.api_key,
                ["anthropic-version"] = "2023-06-01",
              }
            end,
            models = {
              "claude-opus-4-6-20260301",
              "claude-sonnet-4-6-20260301",
              "claude-haiku-4-5-20251001",
            },
            preprocess_payload = function(payload)
              for _, message in ipairs(payload.messages) do
                message.content = message.content:gsub("^%s*(.-)%s*$", "%1")
              end
              if payload.messages[1] and payload.messages[1].role == "system" then
                payload.system = payload.messages[1].content
                table.remove(payload.messages, 1)
              end
              return payload
            end,
          },
          gemini = {
            name = "gemini",
            endpoint = function(self)
              return "https://generativelanguage.googleapis.com/v1beta/models/"
                .. self._model
                .. ":streamGenerateContent?alt=sse"
            end,
            model_endpoint = function(self)
              return { "https://generativelanguage.googleapis.com/v1beta/models?key=" .. self.api_key }
            end,
            api_key = os.getenv("GOOGLE_AI_API_KEY"),
            params = {
              chat = { temperature = 1.1, topP = 1, topK = 10, maxOutputTokens = 8192 },
              command = { temperature = 0.8, topP = 1, topK = 10, maxOutputTokens = 8192 },
            },
            topic = {
              model = "gemini-1.5-flash",
              params = { maxOutputTokens = 64 },
            },
            headers = function(self)
              return {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = self.api_key,
              }
            end,
            models = {
              "gemini-2.5-flash-preview-05-20",
              "gemini-2.5-pro-preview-05-06",
              "gemini-1.5-pro-latest",
              "gemini-1.5-flash-latest",
            },
            preprocess_payload = function(payload)
              local contents = {}
              local system_instruction = nil
              for _, message in ipairs(payload.messages) do
                if message.role == "system" then
                  system_instruction = { parts = { { text = message.content } } }
                else
                  local role = message.role == "assistant" and "model" or "user"
                  table.insert(
                    contents,
                    { role = role, parts = { { text = message.content:gsub("^%s*(.-)%s*$", "%1") } } }
                  )
                end
              end
              local gemini_payload = {
                contents = contents,
                generationConfig = {
                  temperature = payload.temperature,
                  topP = payload.topP or payload.top_p,
                  maxOutputTokens = payload.max_tokens or payload.maxOutputTokens,
                },
              }
              if system_instruction then
                gemini_payload.systemInstruction = system_instruction
              end
              return gemini_payload
            end,
            process_stdout = function(response)
              if not response or response == "" then
                return nil
              end
              local success, decoded = pcall(vim.json.decode, response)
              if
                success
                and decoded.candidates
                and decoded.candidates[1]
                and decoded.candidates[1].content
                and decoded.candidates[1].content.parts
                and decoded.candidates[1].content.parts[1]
              then
                return decoded.candidates[1].content.parts[1].text
              end
              return nil
            end,
          },
          groq = {
            name = "groq",
            endpoint = "https://api.groq.com/openai/v1/chat/completions",
            api_key = os.getenv("GROQ_API_KEY"),
            params = {
              chat = { temperature = 1.1, top_p = 1 },
              command = { temperature = 1.1, top_p = 1 },
            },
            topic = {
              model = "llama-3.3-70b-versatile",
              params = { max_tokens = 64 },
            },
            models = {
              "llama-3.3-70b-versatile",
              "llama-3.1-70b-versatile",
              "mixtral-8x7b-32768",
            },
          },
          openai = {
            name = "openai",
            endpoint = "https://api.openai.com/v1/responses",
            model_endpoint = "https://api.openai.com/v1/models",
            api_key = os.getenv("OPENAI_API_KEY"),
            params = {
              chat = { temperature = 1.1, top_p = 1 },
              command = { temperature = 1.1, top_p = 1 },
            },
            topic = {
              model = "gpt-5-mini",
              params = { max_tokens = 64 },
            },
            models = {
              "gpt-5.4",
              "gpt-5.4-pro",
              "gpt-5.2-codex",
              "gpt-5-mini",
            },
            preprocess_payload = function(payload)
              -- Remove messages with empty content
              local filtered_messages = {}
              for _, message in ipairs(payload.messages) do
                local content = message.content:gsub("^%s*(.-)%s*$", "%1")
                if content ~= "" then
                  message.content = content
                  table.insert(filtered_messages, message)
                end
              end
              payload.messages = filtered_messages
              return payload
            end,
          },
        },
        -- UI enhancements
        enable_preview_mode = true,
        show_context_hints = true,
        spinner_type = "star",
        chat_free_cursor = false,
      })
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { prefix, group = "Parrot", icon = "🦜", mode = { "n", "v" } },
      },
    },
  },
}
