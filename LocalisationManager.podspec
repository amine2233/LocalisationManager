Pod::Spec.new do |s|
		s.name 				= "LocalisationManager"
		s.version 			= "0.1.0"
		s.summary         	= "Sort description of 'LocalisationManager' framework"
	    s.homepage        	= "https://github.com/amine2233/LocalisationManager"
	    s.license           = { type: 'MIT', file: 'LICENSE' }
	    s.author            = { 'Amine Bensalah' => 'amine.bensalah@outlook.com' }
	    s.ios.deployment_target = '12.0'
	    s.osx.deployment_target = '10.13'
	    s.tvos.deployment_target = '12.0'
	    s.watchos.deployment_target = '5.0'
	    s.requires_arc = true
	    s.source            = { :git => "https://github.com/amine2233/LocalisationManager.git", :tag => s.version.to_s }
	    s.source_files      = "Sources/**/*.swift"
	    s.exclude_files		= 'LICENSE'
	    s.pod_target_xcconfig = {
    		'SWIFT_VERSION' => '5.0'
  		}
  		s.module_name = s.name
		s.swift_version = '5.0'
		s.framework    = 'CoreLocation'
		s.ios.framework  = 'UIKit'
		s.test_spec 'Tests' do |test_spec|
			test_spec.source_files = 'Tests/**/*.{swift}'
		end
	end
