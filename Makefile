
compile-llvm-ir: 
	./compile.sh llvm-ir

compile-asm: 
	./compile.sh asm

compile-ast:
	./compile.sh ast

clean:
	rm -rf $(DST_DIR)

help: ## Display this help screen
	@grep -h \
		-E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

doc: ## Generate and tests docs including private items
	@cargo doc --no-deps --all --document-private-items

fmt: ## Check whether the code is formated correctly
	@cargo check --all-features
	@cargo fmt --all -- --check

clippy: ## Run clippy checks over all workspace members
	@cargo check --all-features
	@cargo clippy --all-features --all-targets

.PHONY: compile-llvm-ir compile-asm compile-ast clean fmt clippy doc help
