require "crystal-kramdown-asciidoc/src/kramdown_asciidoc"
require "crystal-asciidoctor"
require "crystal-asciidoctor-pdf/src/asciidoctor_pdf"
require "crystal-asciidoctor-epub3"

# CrystalMarkdown is a universal Markdown converter for Crystal.
#
# It chains crystal-kramdown-asciidoc (Markdown -> AsciiDoc) with the
# crystal-asciidoctor ecosystem (AsciiDoc -> HTML, PDF, EPUB) to provide
# a single, unified API for converting Markdown to multiple output formats.
#
# ```
# html = CrystalMarkdown.to_html("# Hello\n\nThis is **bold**.")
# adoc = CrystalMarkdown.to_asciidoc("# Hello\n\nThis is **bold**.")
# CrystalMarkdown.to_pdf_file("# Hello", "output.pdf")
# CrystalMarkdown.to_epub_file("# Hello", "output.epub")
# ```
module CrystalMarkdown
  VERSION = "0.1.0"

  # Convert Markdown to AsciiDoc (intermediate format).
  #
  # ```
  # adoc = CrystalMarkdown.to_asciidoc("# Title\n\nParagraph.")
  # # => "= Title\n\nParagraph."
  # ```
  def self.to_asciidoc(markdown : String) : String
    KramdownAsciidoc.convert(markdown)
  end

  # Convert Markdown to HTML.
  #
  # ```
  # html = CrystalMarkdown.to_html("# Title\n\n**Bold** text.")
  # ```
  def self.to_html(markdown : String) : String
    asciidoc = to_asciidoc(markdown)
    Asciidoctor.convert(asciidoc, {"backend" => "html5", "standalone" => "false"})
  end

  # Convert Markdown to a standalone HTML document.
  #
  # ```
  # html = CrystalMarkdown.to_html_standalone("# Title\n\nContent.")
  # ```
  def self.to_html_standalone(markdown : String) : String
    asciidoc = to_asciidoc(markdown)
    Asciidoctor.convert(asciidoc, {"backend" => "html5", "standalone" => "true"})
  end

  # Convert Markdown to PDF and return the bytes.
  #
  # The conversion uses a temporary file internally, since the PDF converter
  # writes to disk as part of the rendering pipeline.
  #
  # ```
  # bytes = CrystalMarkdown.to_pdf("# Title\n\nContent.")
  # ```
  def self.to_pdf(markdown : String) : Bytes
    tmpfile = File.tempfile("crystal-markdown", ".pdf")
    begin
      to_pdf_file(markdown, tmpfile.path)
      File.read(tmpfile.path).to_slice.dup
    ensure
      tmpfile.delete
    end
  end

  # Convert Markdown to PDF and write to the specified file.
  #
  # ```
  # CrystalMarkdown.to_pdf_file("# Title\n\nContent.", "output.pdf")
  # ```
  def self.to_pdf_file(markdown : String, path : String)
    asciidoc = to_asciidoc(markdown)
    doc = Asciidoctor.load(asciidoc, {"backend" => "pdf", "safe" => "safe"})
    doc.attributes["outfile"] = File.expand_path(path)
    converter = doc.converter || AsciidoctorPDF::Converter.new
    converter.convert(doc)
  end

  # Convert Markdown to EPUB and return the bytes.
  #
  # ```
  # bytes = CrystalMarkdown.to_epub("# Title\n\nContent.")
  # ```
  def self.to_epub(markdown : String) : Bytes
    asciidoc = to_asciidoc(markdown)
    doc = Asciidoctor.load(asciidoc, {"backend" => "html5", "safe" => "safe"})
    converter = AsciidoctorEpub::Converter.new
    converter.convert(doc)
  end

  # Convert Markdown to EPUB and write to the specified file.
  #
  # ```
  # CrystalMarkdown.to_epub_file("# Title\n\nContent.", "output.epub")
  # ```
  def self.to_epub_file(markdown : String, path : String)
    asciidoc = to_asciidoc(markdown)
    doc = Asciidoctor.load(asciidoc, {"backend" => "html5", "safe" => "safe"})
    converter = AsciidoctorEpub::Converter.new
    converter.convert_to_file(doc, path)
  end

  # Generate a sample Markdown document to demonstrate conversion capabilities.
  def self.sample_markdown : String
    <<-MD
    # Crystal Markdown

    A universal Markdown converter for Crystal.

    ## Features

    - **PDF** output via crystal-asciidoctor-pdf
    - **EPUB** output via crystal-asciidoctor-epub3
    - **HTML** output via crystal-asciidoctor
    - **AsciiDoc** intermediate format via crystal-kramdown-asciidoc

    ## Code Example

    ```crystal
    html = CrystalMarkdown.to_html("# Hello\\n\\nWorld.")
    ```

    ## Table

    | Format   | Extension | Library                    |
    |----------|-----------|----------------------------|
    | HTML     | .html     | crystal-asciidoctor        |
    | PDF      | .pdf      | crystal-asciidoctor-pdf    |
    | EPUB     | .epub     | crystal-asciidoctor-epub3  |
    | AsciiDoc | .adoc     | crystal-kramdown-asciidoc  |

    ## Blockquote

    > Markdown is the universal input format.
    > AsciiDoc is the universal intermediate format.

    ---

    *Built with Crystal and the Asciidoctor ecosystem.*
    MD
  end
end
