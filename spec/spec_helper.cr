require "spec"
require "../src/carbon"
require "./support/**"
require "dotenv"

Dotenv.load

Spec.before_each do
  Carbon::DevAdapter.reset
end
