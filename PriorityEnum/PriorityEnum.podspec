Pod::Spec.new do |spec|

  spec.name         = "PriorityEnum"
  spec.version      = "0.0.1"
  spec.summary      = "Enum for task priority."

  spec.swift_version = "5.0"
  spec.ios.deployment_target = "13.0"

  spec.homepage     = "http://EXAMPLE/PriorityEnum"

  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  spec.author       = { "Nick" => "n9163293481@gmail.com" }

  spec.source       = { :path => "/PriorityEnum"}

  spec.source_files  = "Priority.swift", "PriorityEnum/**/*.{swift,h,m}"

end
