import XCTest
import SwiftTreeSitter
import TreeSitterAkbs

final class TreeSitterAkbsTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_akbs())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Akbs grammar")
    }
}
