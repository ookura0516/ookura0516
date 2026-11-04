# iOS のウィジェット（WidgetKit）のターゲットを Runner.xcodeproj に足すスクリプト。
# Xcode のない環境で使った。もう一度実行しても重ねて足さない。
#   gem install xcodeproj && ruby tool/add_ios_widget_target.rb
require 'xcodeproj'

ios = File.expand_path('../ios', __dir__)
project = Xcodeproj::Project.open(File.join(ios, 'Runner.xcodeproj'))
name = 'TanzakuWidgetExtension'
abort "#{name} はもうあります" if project.targets.any? { |t| t.name == name }

runner = project.targets.find { |t| t.name == 'Runner' }
widget = project.new_target(:app_extension, name, :ios, '17.0', nil, :swift)

group = project.main_group.new_group('TanzakuWidget', 'TanzakuWidget')
swift = group.new_reference('TanzakuWidget.swift')
group.new_reference('Info.plist')
group.new_reference('TanzakuWidget.entitlements')
widget.add_file_references([swift])

%w[WidgetKit SwiftUI].each do |fw|
  ref = project.frameworks_group.new_reference("System/Library/Frameworks/#{fw}.framework", :sdk_root)
  ref.name = "#{fw}.framework"
  widget.frameworks_build_phase.add_file_reference(ref, true)
end

# バージョンは Flutter の pubspec から（Generated.xcconfig の FLUTTER_BUILD_NAME / NUMBER）。
generated = project.files.find { |f| f.path == 'Flutter/Generated.xcconfig' }
widget.build_configurations.each do |c|
  c.base_configuration_reference = generated
  s = c.build_settings
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.ookura.tanzaku.TanzakuWidget'
  s['INFOPLIST_FILE'] = 'TanzakuWidget/Info.plist'
  s['CODE_SIGN_ENTITLEMENTS'] = 'TanzakuWidget/TanzakuWidget.entitlements'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  s['SWIFT_VERSION'] = '5.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['SKIP_INSTALL'] = 'YES'
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
  s['CODE_SIGN_STYLE'] = 'Automatic'
end

# Flutter の Profile 構成（new_target は Debug / Release しか作らない）
unless widget.build_configurations.any? { |c| c.name == 'Profile' }
  release = widget.build_configurations.find { |c| c.name == 'Release' }
  profile = widget.add_build_configuration('Profile', :release)
  profile.build_settings = release.build_settings.dup
  profile.base_configuration_reference = generated
end

runner.build_configurations.each do |c|
  c.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end
project.main_group['Runner'].new_reference('Runner.entitlements')

# 本体に埋め込む。Flutter の「Thin Binary」より前に置かないと、ビルドが循環する。
runner.add_dependency(widget)
embed = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
embed.name = 'Embed Foundation Extensions'
embed.symbol_dst_subfolder_spec = :plug_ins
embed.add_file_reference(widget.product_reference, true).settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
thin = runner.build_phases.index { |p| p.respond_to?(:name) && p.name == 'Thin Binary' }
runner.build_phases.insert(thin || runner.build_phases.size, embed)

project.save
puts "added #{name}"
