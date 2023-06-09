require "spec"
require "../src/carbon"
require "./support/**"
require "lucky_env"
require "lucky_template/spec"

LuckyEnv.load?(".env")

Spec.before_each do
  Carbon::DevAdapter.reset
end
