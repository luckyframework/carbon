require "spec"
require "../src/carbon"
require "./support/**"
require "lucky_env"

LuckyEnv.load?(".env")

Spec.before_each do
  Carbon::DevAdapter.reset
end
