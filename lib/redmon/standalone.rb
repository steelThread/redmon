require 'rake'
require 'redis'

task :run do
  Redmon.run
end

Rake.application.init('redmon')
Rake.application.top_level