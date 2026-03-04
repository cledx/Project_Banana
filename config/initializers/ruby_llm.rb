# RubyLLM configuration. Add the API keys you need to .env (or ENV).
# See https://rubyllm.com/configuration
#
# GitHub Azure free developer: use Azure AI / Foundry endpoint + key in .env
#
RubyLLM.configure do |config|
  config.openai_api_key = ENV["GITHUB_TOKEN"]
  config.openai_api_base = "https://models.inference.ai.azure.com"

  # Azure inference uses deployment/model names like gpt-4o, gpt-4o-mini — set to one you have
  config.default_model = ENV.fetch("RUBY_LLM_DEFAULT_MODEL", "gpt-4o")
end
