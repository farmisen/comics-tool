require 'nokogiri'
require 'slop'
require_relative 'comics'

include Comics

opts = Slop.parse(help: true, strict: true)  do

  command 'fix_loc' do
    on 'l', 'location', 'new location', argument: :optional
    on 'i', 'input', 'xml file or folder', argument: :required
    on 'o', 'output', 'output', argument: :optional

    run do |opts, args|
      fix_location(opts[:input], opts[:output] || STDOUT, opts[:location])
    end
  end

  command 'csv' do
    on 'i', 'input', 'xml file', argument: :required
    on 'o', 'output', 'output', argument: :optional

    run do |opts, args|
      export_to_csv(opts[:input], opts[:output] || STDOUT)
    end
  end

end

