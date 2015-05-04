require 'jackal'
require 'jackal-commander/version'

module Jackal
  module Commander
    autoload :Executor, 'jackal-commander/executor'
  end
end

Jackal.service(
  :commander,
  :description => 'Run arbitrary commands',
  :configuration => {
    :actions => {
      :description => 'Named commands payload will reference',
      :type => :hash
    }
  }
)
