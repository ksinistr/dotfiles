return {
	cmd = { "golangci-lint-langserver" },
	init_options = {
		command = { "golangci-lint", "run", "--output.json.path", "stdout", "--output.text.path", "stderr", "--output.tab.path", "stderr", "--show-stats=false" },
	},
}
