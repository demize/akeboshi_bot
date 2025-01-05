package tree_sitter_akbs_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_akbs "github.com/demize/akeboshi_bot/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_akbs.Language())
	if language == nil {
		t.Errorf("Error loading Akbs grammar")
	}
}
