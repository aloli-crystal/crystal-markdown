require "option_parser"
require "./markdown"

# Point d'entrée CLI du binaire `markdown`. Convertit un fichier
# Markdown en HTML, PDF, EPUB ou AsciiDoc.
#
# Le module `Markdown` reste utilisable en bibliothèque via
# `require "markdown"`.

target_format = "html"
output_path : String? = nil
standalone = true

parser = OptionParser.new do |p|
  p.banner = <<-BANNER
    Usage : markdown FICHIER.md [options]

    Convertisseur Markdown universel — chaîne kramdown-asciidoc puis
    le pipeline asciidoctor (HTML/PDF/EPUB) pour produire le format
    cible. Le format est déduit de l'extension de sortie OU de l'option
    `-t / --to`.

    Exemples :
      markdown rapport.md -t pdf            → rapport.pdf
      markdown rapport.md -t epub           → rapport.epub
      markdown rapport.md -o doc.html       → doc.html (HTML)
      markdown rapport.md -t adoc           → rapport.adoc

    Options :
    BANNER

  p.on("-t FORMAT", "--to=FORMAT", "Format de sortie : html | pdf | epub | adoc (défaut : html)") do |v|
    target_format = v.downcase
  end
  p.on("-o FICHIER", "--output=FICHIER", "Fichier de sortie (défaut : même base que l'entrée)") do |v|
    output_path = v
  end
  p.on("--no-standalone", "HTML : sortie partielle (sans <html>/<head>) — défaut HTML standalone") do
    standalone = false
  end

  p.separator ""
  p.separator "Aide :"
  p.on("-v", "--version", "Affiche la version") do
    puts "markdown #{Markdown::VERSION}"
    exit 0
  end
  p.on("-h", "--help", "Affiche l'aide") do
    puts p
    exit 0
  end

  p.invalid_option do |flag|
    STDERR.puts "Option inconnue : #{flag}"
    STDERR.puts p
    exit 1
  end
end

positional = [] of String
parser.unknown_args { |args| positional = args }
parser.parse(ARGV)

if positional.empty?
  STDERR.puts "Erreur : aucun fichier d'entrée"
  STDERR.puts parser
  exit 1
end

input = positional.first
unless File.exists?(input)
  STDERR.puts "Erreur : fichier introuvable : #{input}"
  exit 1
end

# Si -o est fourni mais pas -t, on déduit le format de l'extension
if (out_user = output_path) && !["html", "pdf", "epub", "adoc"].includes?(target_format)
  ext = File.extname(out_user).lstrip('.').downcase
  target_format = ext if ["html", "pdf", "epub", "adoc"].includes?(ext)
end

unless ["html", "pdf", "epub", "adoc"].includes?(target_format)
  STDERR.puts "Erreur : format inconnu « #{target_format} » (valides : html, pdf, epub, adoc)"
  exit 1
end

# Sortie auto si pas de -o : remplace .md par l'extension cible
out_file : String = if explicit = output_path
  explicit
else
  base = input.sub(/\.[mM][dD]$/, "")
  "#{base}.#{target_format}"
end

source = File.read(input)

case target_format
when "html"
  result = standalone ? Markdown.to_html_standalone(source) : Markdown.to_html(source)
  File.write(out_file, result)
when "adoc"
  File.write(out_file, Markdown.to_asciidoc(source))
when "pdf"
  Markdown.to_pdf_file(source, out_file)
when "epub"
  Markdown.to_epub_file(source, out_file)
end

puts "✓ #{out_file}"
