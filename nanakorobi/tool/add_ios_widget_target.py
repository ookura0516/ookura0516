"""ios/Runner.xcodeproj に、ホーム画面のウィジェット（NanakorobiWidgetExtension）のターゲットを足す。

Xcode の「New Target → Widget Extension」と同じものを、手で書き足す（keshiin/tool の写し）。
あわせて Runner に App Group の entitlements（Runner/Runner.entitlements）を設定する。
2回目以降は何もしない（ターゲットがすでにあれば終わる）。

  python3 tool/add_ios_widget_target.py
"""
import pathlib
import re
import sys

PBX = pathlib.Path(__file__).resolve().parent.parent / 'ios/Runner.xcodeproj/project.pbxproj'
s = PBX.read_text()
if 'NanakorobiWidgetExtension' in s:
    print('already added')
    sys.exit(0)

# Flutter のテンプレートが使っている固定の ID。
RUNNER = '97C146ED1CF9000F007C117D'
PROJECT = '97C146E61CF9000F007C117D'
DEBUG_XC = '9740EEB21CF90195004384FC'
RELEASE_XC = '7AFA3C8E1D35360C0083082E'

WIDGET = 'NanakorobiWidget'              # フォルダと Swift ファイルの名前
TARGET = 'NanakorobiWidgetExtension'     # ターゲットと .appex の名前
BUNDLE = 'com.ookura.nanakorobi.NanakorobiWidget'

ids = {k: 'C7A2E1' + f'{i:018X}' for i, k in enumerate([
    'swift_ref', 'plist_ref', 'ent_ref', 'appex_ref',
    'swift_build', 'appex_embed',
    'group', 'sources', 'frameworks', 'resources', 'target',
    'proxy', 'dependency', 'embed_phase',
    'cfg_debug', 'cfg_release', 'cfg_profile', 'cfg_list',
])}
I = ids


def section_end(name):
    return f'/* End {name} section */'


def add_to_section(text, name, body):
    marker = section_end(name)
    if marker not in text:
        text = text.replace('/* End PBXBuildFile section */',
                            '/* End PBXBuildFile section */\n\n'
                            f'/* Begin {name} section */\n{marker}', 1)
    i = text.index(marker)
    return text[:i] + body + text[i:]


s = add_to_section(s, 'PBXBuildFile',
    f'\t\t{I["swift_build"]} /* {WIDGET}.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {I["swift_ref"]} /* {WIDGET}.swift */; }};\n'
    f'\t\t{I["appex_embed"]} /* {TARGET}.appex in Embed Foundation Extensions */ = {{isa = PBXBuildFile; fileRef = {I["appex_ref"]} /* {TARGET}.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};\n')

s = add_to_section(s, 'PBXContainerItemProxy',
    f'\t\t{I["proxy"]} /* PBXContainerItemProxy */ = {{\n'
    f'\t\t\tisa = PBXContainerItemProxy;\n'
    f'\t\t\tcontainerPortal = {PROJECT} /* Project object */;\n'
    f'\t\t\tproxyType = 1;\n'
    f'\t\t\tremoteGlobalIDString = {I["target"]};\n'
    f'\t\t\tremoteInfo = {TARGET};\n'
    f'\t\t}};\n')

s = add_to_section(s, 'PBXCopyFilesBuildPhase',
    f'\t\t{I["embed_phase"]} /* Embed Foundation Extensions */ = {{\n'
    f'\t\t\tisa = PBXCopyFilesBuildPhase;\n'
    f'\t\t\tbuildActionMask = 2147483647;\n'
    f'\t\t\tdstPath = "";\n'
    f'\t\t\tdstSubfolderSpec = 13;\n'
    f'\t\t\tfiles = (\n'
    f'\t\t\t\t{I["appex_embed"]} /* {TARGET}.appex in Embed Foundation Extensions */,\n'
    f'\t\t\t);\n'
    f'\t\t\tname = "Embed Foundation Extensions";\n'
    f'\t\t\trunOnlyForDeploymentPostprocessing = 0;\n'
    f'\t\t}};\n')

s = add_to_section(s, 'PBXFileReference',
    f'\t\t{I["swift_ref"]} /* {WIDGET}.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {WIDGET}.swift; sourceTree = "<group>"; }};\n'
    f'\t\t{I["plist_ref"]} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};\n'
    f'\t\t{I["ent_ref"]} /* {WIDGET}.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = {WIDGET}.entitlements; sourceTree = "<group>"; }};\n'
    f'\t\t{I["appex_ref"]} /* {TARGET}.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = {TARGET}.appex; sourceTree = BUILT_PRODUCTS_DIR; }};\n')

s = add_to_section(s, 'PBXFrameworksBuildPhase',
    f'\t\t{I["frameworks"]} /* Frameworks */ = {{\n'
    f'\t\t\tisa = PBXFrameworksBuildPhase;\n'
    f'\t\t\tbuildActionMask = 2147483647;\n'
    f'\t\t\tfiles = (\n\t\t\t);\n'
    f'\t\t\trunOnlyForDeploymentPostprocessing = 0;\n'
    f'\t\t}};\n')

s = add_to_section(s, 'PBXGroup',
    f'\t\t{I["group"]} /* {WIDGET} */ = {{\n'
    f'\t\t\tisa = PBXGroup;\n'
    f'\t\t\tchildren = (\n'
    f'\t\t\t\t{I["swift_ref"]} /* {WIDGET}.swift */,\n'
    f'\t\t\t\t{I["plist_ref"]} /* Info.plist */,\n'
    f'\t\t\t\t{I["ent_ref"]} /* {WIDGET}.entitlements */,\n'
    f'\t\t\t);\n'
    f'\t\t\tpath = {WIDGET};\n'
    f'\t\t\tsourceTree = "<group>";\n'
    f'\t\t}};\n')
# メイングループと Products に足す
main_group = '\t\t\t\t331C8082294A63A400263BE5 /* RunnerTests */,\n\t\t\t);'
assert main_group in s, 'main group'
s = s.replace(main_group,
              f'\t\t\t\t331C8082294A63A400263BE5 /* RunnerTests */,\n\t\t\t\t{I["group"]} /* {WIDGET} */,\n\t\t\t);', 1)
products = '\t\t\t\t331C8081294A63A400263BE5 /* RunnerTests.xctest */,\n'
assert products in s, 'products'
s = s.replace(products,
              f'\t\t\t\t331C8081294A63A400263BE5 /* RunnerTests.xctest */,\n\t\t\t\t{I["appex_ref"]} /* {TARGET}.appex */,\n', 1)

s = add_to_section(s, 'PBXNativeTarget',
    f'\t\t{I["target"]} /* {TARGET} */ = {{\n'
    f'\t\t\tisa = PBXNativeTarget;\n'
    f'\t\t\tbuildConfigurationList = {I["cfg_list"]} /* Build configuration list for PBXNativeTarget "{TARGET}" */;\n'
    f'\t\t\tbuildPhases = (\n'
    f'\t\t\t\t{I["sources"]} /* Sources */,\n'
    f'\t\t\t\t{I["frameworks"]} /* Frameworks */,\n'
    f'\t\t\t\t{I["resources"]} /* Resources */,\n'
    f'\t\t\t);\n'
    f'\t\t\tbuildRules = (\n\t\t\t);\n'
    f'\t\t\tdependencies = (\n\t\t\t);\n'
    f'\t\t\tname = {TARGET};\n'
    f'\t\t\tproductName = {TARGET};\n'
    f'\t\t\tproductReference = {I["appex_ref"]} /* {TARGET}.appex */;\n'
    f'\t\t\tproductType = "com.apple.product-type.app-extension";\n'
    f'\t\t}};\n')
# Runner：ウィジェットに依存し、「Thin Binary」より前に埋め込む（後ろだと依存の循環になる）
phases = '\t\t\t\t9705A1C41CF9048500538489 /* Embed Frameworks */,\n\t\t\t\t3B06AD1E1E4923F5004D2608 /* Thin Binary */,'
assert phases in s, 'runner build phases'
s = s.replace(phases,
              f'\t\t\t\t9705A1C41CF9048500538489 /* Embed Frameworks */,\n\t\t\t\t{I["embed_phase"]} /* Embed Foundation Extensions */,\n\t\t\t\t3B06AD1E1E4923F5004D2608 /* Thin Binary */,', 1)
runner_deps = '\t\t\tdependencies = (\n\t\t\t);\n\t\t\tname = Runner;'
assert runner_deps in s, 'runner dependencies'
s = s.replace(runner_deps,
              f'\t\t\tdependencies = (\n\t\t\t\t{I["dependency"]} /* PBXTargetDependency */,\n\t\t\t);\n\t\t\tname = Runner;', 1)

# プロジェクト：ターゲットの一覧
targets = '\t\t\t\t331C8080294A63A400263BE5 /* RunnerTests */,\n\t\t\t);\n\t\t};\n/* End PBXProject section */'
assert targets in s, 'project targets'
s = s.replace(targets,
              f'\t\t\t\t331C8080294A63A400263BE5 /* RunnerTests */,\n\t\t\t\t{I["target"]} /* {TARGET} */,\n\t\t\t);\n\t\t}};\n/* End PBXProject section */', 1)
attrs = '\t\t\t\t\t97C146ED1CF9000F007C117D = {\n\t\t\t\t\t\tCreatedOnToolsVersion = 7.3.1;'
assert attrs in s, 'target attributes'
s = s.replace(attrs,
              f'\t\t\t\t\t{I["target"]} = {{\n\t\t\t\t\t\tCreatedOnToolsVersion = 16.0;\n\t\t\t\t\t}};\n'
              '\t\t\t\t\t97C146ED1CF9000F007C117D = {\n\t\t\t\t\t\tCreatedOnToolsVersion = 7.3.1;', 1)

s = add_to_section(s, 'PBXResourcesBuildPhase',
    f'\t\t{I["resources"]} /* Resources */ = {{\n'
    f'\t\t\tisa = PBXResourcesBuildPhase;\n'
    f'\t\t\tbuildActionMask = 2147483647;\n'
    f'\t\t\tfiles = (\n\t\t\t);\n'
    f'\t\t\trunOnlyForDeploymentPostprocessing = 0;\n'
    f'\t\t}};\n')
s = add_to_section(s, 'PBXSourcesBuildPhase',
    f'\t\t{I["sources"]} /* Sources */ = {{\n'
    f'\t\t\tisa = PBXSourcesBuildPhase;\n'
    f'\t\t\tbuildActionMask = 2147483647;\n'
    f'\t\t\tfiles = (\n'
    f'\t\t\t\t{I["swift_build"]} /* {WIDGET}.swift in Sources */,\n'
    f'\t\t\t);\n'
    f'\t\t\trunOnlyForDeploymentPostprocessing = 0;\n'
    f'\t\t}};\n')
s = add_to_section(s, 'PBXTargetDependency',
    f'\t\t{I["dependency"]} /* PBXTargetDependency */ = {{\n'
    f'\t\t\tisa = PBXTargetDependency;\n'
    f'\t\t\ttarget = {I["target"]} /* {TARGET} */;\n'
    f'\t\t\ttargetProxy = {I["proxy"]} /* PBXContainerItemProxy */;\n'
    f'\t\t}};\n')


def cfg(key, name, base, debug):
    extra = ('\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";\n'
             '\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";\n') if debug else \
            '\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;\n\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";\n'
    return (f'\t\t{I[key]} /* {name} */ = {{\n'
            f'\t\t\tisa = XCBuildConfiguration;\n'
            f'\t\t\tbaseConfigurationReference = {base};\n'
            f'\t\t\tbuildSettings = {{\n'
            f'\t\t\t\tAPPLICATION_EXTENSION_API_ONLY = YES;\n'
            f'\t\t\t\tCLANG_ENABLE_MODULES = YES;\n'
            f'\t\t\t\tCODE_SIGN_ENTITLEMENTS = {WIDGET}/{WIDGET}.entitlements;\n'
            f'\t\t\t\tCURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";\n'
            f'\t\t\t\tGENERATE_INFOPLIST_FILE = NO;\n'
            f'\t\t\t\tINFOPLIST_FILE = {WIDGET}/Info.plist;\n'
            f'\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;\n'
            f'\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (\n\t\t\t\t\t"$(inherited)",\n\t\t\t\t\t"@executable_path/Frameworks",\n\t\t\t\t\t"@executable_path/../../Frameworks",\n\t\t\t\t);\n'
            f'\t\t\t\tMARKETING_VERSION = "$(FLUTTER_BUILD_NAME)";\n'
            f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {BUNDLE};\n'
            f'\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";\n'
            f'\t\t\t\tSKIP_INSTALL = YES;\n'
            f'{extra}'
            f'\t\t\t\tSWIFT_VERSION = 5.0;\n'
            f'\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";\n'
            f'\t\t\t}};\n'
            f'\t\t\tname = {name};\n'
            f'\t\t}};\n')


s = add_to_section(s, 'XCBuildConfiguration',
    cfg('cfg_debug', 'Debug', f'{DEBUG_XC} /* Debug.xcconfig */', True) +
    cfg('cfg_release', 'Release', f'{RELEASE_XC} /* Release.xcconfig */', False) +
    cfg('cfg_profile', 'Profile', f'{RELEASE_XC} /* Release.xcconfig */', False))
s = add_to_section(s, 'XCConfigurationList',
    f'\t\t{I["cfg_list"]} /* Build configuration list for PBXNativeTarget "{TARGET}" */ = {{\n'
    f'\t\t\tisa = XCConfigurationList;\n'
    f'\t\t\tbuildConfigurations = (\n'
    f'\t\t\t\t{I["cfg_debug"]} /* Debug */,\n'
    f'\t\t\t\t{I["cfg_release"]} /* Release */,\n'
    f'\t\t\t\t{I["cfg_profile"]} /* Profile */,\n'
    f'\t\t\t);\n'
    f'\t\t\tdefaultConfigurationIsVisible = 0;\n'
    f'\t\t\tdefaultConfigurationName = Release;\n'
    f'\t\t}};\n')

# Runner：App Group の entitlements（Debug / Release / Profile の3つの buildSettings）
runner_ids = re.findall(r'(\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com\.ookura\.nanakorobi;\n)', s)
assert len(runner_ids) == 3, f'runner build settings: {len(runner_ids)}'
s = s.replace('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.ookura.nanakorobi;\n',
              '\t\t\t\tCODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;\n'
              '\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.ookura.nanakorobi;\n')

for k, v in ids.items():
    assert s.count(v) >= 2, k
PBX.write_text(s)
print(f'added {TARGET}')
