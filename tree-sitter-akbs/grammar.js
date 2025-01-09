/**
 * @file Grammar for generating the output of bot commands
 * @author demize <demize@unstable.systems>
 * @license 0BSD
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "akbs",

  rules: {
    input: ($) => seq(optional($.command), repeat($._expression)),
    command: ($) => seq("/", token.immediate("announce")), // only /announce is supported, but other commands might be eventually
    _expression: ($) =>
      prec.right(
        seq(
          repeat($.punctuation),
          choice($.variable, $.function, $.identifier, $.alnum),
          repeat($.punctuation),
        ),
      ),
    variable: ($) => seq("$(", field("name", $.identifier), ")"),
    function: ($) =>
      seq(
        "$(",
        field("name", $.identifier),
        field("parameters", repeat1($.parameter)),
        ")",
      ),
    parameter: ($) =>
      choice(
        $._expression,
        seq('"', prec.left(repeat($._expression)), '"'),
        seq("'", prec.left(repeat($._expression)), "'"),
        seq("`", prec.left(repeat($._expression)), "`"),
      ),
    punctuation: ($) =>
      prec(
        -1,
        choice(
          ",",
          ".",
          "/",
          ";",
          "'",
          "[",
          "]",
          "!",
          "@",
          "#",
          "$",
          "%",
          "^",
          "&",
          "*",
          "(",
          ")",
          "-",
          "_",
          "=",
          "+",
          "<",
          ">",
          "?",
          ":",
          "\\",
          "{",
          "}",
        ),
      ),
    alnum: ($) => /[a-zA-Z0-9-_]+/,
    identifier: ($) => choice(/\d/, /[a-z]+/),
  },
  inline: ($) => [$.punctuation],
});
