# Don't allow PRs without a description
if github.pr_body.length < 5
        fail "Please provide a summary in the Pull Request description"
end

# Always ensure we assign someone
warn "This PR does not have any assignees yet." unless github.pr_json["assignee"]

# Warn when there is a big PR
warn("Big PR, try to keep changes smaller if you can") if git.lines_of_code > 500

# Thanks other people!
message("Thanks @#{github.pr_author}! :tada:") if github.pr_author != "marcosgriselli"

# Lint
swiftlint.verbose = true
swiftlint.config_file = './Example/.swiftlint.yml'
swiftlint.binary_path = './Example/Pods/SwiftLint/swiftlint'
# files_to_lint = (git.modified_files - git.deleted_files) + git.added_files
# files_to_lint.reject! { |f| f.start_with?('Pods/') || f.start_with?('ellaTests/') }
swiftlint.lint_files(
    inline_mode: true,
    additional_swiftlint_args: '--no-force-exclude'
)

# Don't allow XIBs with misplaced views
fail("XIBs must not have misplaced views") if `egrep -r 'misplaced="YES"' --include=\*.{xib,storyboard} Example/SwipeableTabBarController/`.length > 1

# Code coverage
xcov.report(
   scheme: 'SwipeableTabBarController-Example',
   workspace: './Example/SwipeableTabBarController.xcworkspace',
)