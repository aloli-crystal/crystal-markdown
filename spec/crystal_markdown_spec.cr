require "./spec_helper"

describe Markdown do
  describe ".to_asciidoc" do
    it "converts a heading" do
      result = Markdown.to_asciidoc("# Hello")
      result.should contain("= Hello")
    end

    it "converts bold text" do
      result = Markdown.to_asciidoc("This is **bold** text.")
      result.should contain("*bold*")
    end

    it "converts italic text" do
      result = Markdown.to_asciidoc("This is *italic* text.")
      result.should contain("_italic_")
    end

    it "converts inline code" do
      result = Markdown.to_asciidoc("Use `puts` to print.")
      result.should contain("`puts`")
    end

    it "converts a code block" do
      md = "```crystal\nputs \"hello\"\n```"
      result = Markdown.to_asciidoc(md)
      result.should contain("[source,crystal]")
      result.should contain("puts \"hello\"")
    end

    it "converts an unordered list" do
      md = "- item one\n- item two"
      result = Markdown.to_asciidoc(md)
      result.should contain("* item one")
      result.should contain("* item two")
    end

    it "converts an ordered list" do
      md = "1. first\n2. second"
      result = Markdown.to_asciidoc(md)
      result.should contain(". first")
      result.should contain(". second")
    end

    it "converts a blockquote" do
      md = "> This is a quote."
      result = Markdown.to_asciidoc(md)
      result.should contain("____")
      result.should contain("This is a quote.")
    end

    it "converts a link" do
      md = "[Crystal](https://crystal-lang.org)"
      result = Markdown.to_asciidoc(md)
      result.should contain("https://crystal-lang.org")
      result.should contain("Crystal")
    end

    it "converts a horizontal rule" do
      result = Markdown.to_asciidoc("---")
      result.should contain("'''")
    end

    it "preserves multiple paragraphs" do
      md = "First paragraph.\n\nSecond paragraph."
      result = Markdown.to_asciidoc(md)
      result.should contain("First paragraph.")
      result.should contain("Second paragraph.")
    end
  end

  describe ".to_html" do
    it "converts a heading to HTML" do
      result = Markdown.to_html("# Hello")
      result.should contain("<h")
      result.should contain("Hello")
    end

    it "converts bold to HTML" do
      result = Markdown.to_html("This is **bold**.")
      result.should contain("<strong>bold</strong>")
    end

    it "converts a paragraph to HTML" do
      result = Markdown.to_html("Hello world.")
      result.should contain("<p>")
      result.should contain("Hello world.")
    end

    it "converts a code block to HTML" do
      md = "```crystal\nputs \"hi\"\n```"
      result = Markdown.to_html(md)
      result.should contain("<pre")
      result.should contain("<code")
    end

    it "converts a list to HTML" do
      md = "- alpha\n- beta"
      result = Markdown.to_html(md)
      result.should contain("<ul>")
      result.should contain("<li>")
    end
  end

  describe ".to_html_standalone" do
    it "returns a full HTML document" do
      result = Markdown.to_html_standalone("# Title\n\nContent.")
      result.should contain("<!DOCTYPE html>")
      result.should contain("<html")
      result.should contain("</html>")
    end
  end

  describe "VERSION" do
    it "has a version string" do
      Markdown::VERSION.should_not be_empty
    end
  end

  describe ".sample_markdown" do
    it "returns a non-empty sample document" do
      sample = Markdown.sample_markdown
      sample.should_not be_empty
      sample.should contain("# Crystal Markdown")
    end

    it "converts sample to AsciiDoc without error" do
      sample = Markdown.sample_markdown
      result = Markdown.to_asciidoc(sample)
      result.should_not be_empty
    end

    it "converts sample to HTML without error" do
      sample = Markdown.sample_markdown
      result = Markdown.to_html(sample)
      result.should_not be_empty
    end
  end
end
