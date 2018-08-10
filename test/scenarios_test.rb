require_relative 'test_helper'
require 'asciidoctor'
require 'asciidoctor/inline_parser/parser'

describe 'scenario' do
  let(:doc) { ::Asciidoctor::InlineParser.parse input }

  Dir.chdir File.join __dir__, 'scenarios' do
    (Dir.glob '**/*.adoc').each do |input_filename|
      input_stem = input_filename.slice 0, input_filename.length - 5
      scenario_name = input_stem.gsub '/', '::'
      input_filename = File.absolute_path input_filename
      output_filename = File.absolute_path %(#{input_stem}.html)
      describe %(for #{scenario_name}) do
        let(:input) { IO.read input_filename, mode: 'r:UTF-8', newline: :universal }
        let(:expected) { (IO.read output_filename, mode: 'r:UTF-8', newline: :universal).chomp }
        it 'converts inline Asciidoctor syntax to HTML' do
          doc.to_html.must_equal expected
        end
      end
    end
  end
end
