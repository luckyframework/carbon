require "lucky_task"
require "./src/carbon"

Habitat.raise_if_missing_settings!
LuckyTask::Runner.run
