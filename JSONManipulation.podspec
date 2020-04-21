Pod::Spec.new do |s|
    s.name             = 'JSONManipulation'
    s.version          = '0.0.1'
    s.summary          = 'A tool to automate JSON editing and generation'
    s.homepage         = 'https://github.com/baguio/JSONManipulation'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Jhonatan A.' => '' }
    s.preserve_paths = '*'
    s.swift_version = '5.0'
    s.ios.deployment_target = '8.0'
    s.source       = {
      :http => "#{s.homepage}/releases/download/#{s.version}/#{s.name}.zip"
    }
  end
  