require 'sinatra'
require 'hexapdf'
require 'csv'
require 'haml'
require 'stringio'

def index
  CSV.new(IO.read("#{ARGV[0]}/index.csv"), headers: true).read.map{|r| r.to_h}
end

def get_filenames
  filenames = []
  index.each do |row|
    filenames << row['file'] unless filenames.include? row['file']
  end
  return filenames
end

def for_filename filename
  index.select{|r| r['file'] == filename}
end

get '/' do
  @filenames = get_filenames
  haml :home
end

get '/all' do
  search = params[:search]

  @filenames = get_filenames
  @sheets = index.map{|r| r['index'] = @filenames.index(r['file']); r}

  unless search.nil?
    @sheets.select!{|s| s['title'].downcase.include? search.downcase}
  end

  haml :list
end

get '/file/:i' do |i|
  file_index = i.to_i
  @filenames = get_filenames
  filename = @filenames[file_index]
  @sheets = for_filename(filename).map{|r| r['index'] = file_index; r}
  haml :list
end

get '/sheet/:i/:p' do |i, p|

  file_index = i.to_i
  page = p.to_i
  filename = get_filenames[file_index]
  title = params[:title]

  sheet = HexaPDF::Document.new
  pdf = HexaPDF::Document.open("#{ARGV[0]}/#{filename}")

  sheet.pages << sheet.import(pdf.pages[page - 1])

  out = StringIO.new
  sheet.write(out, optimize: true)

  content_type 'application/pdf'
  attachment "#{title}.pdf", :inline
  out.string
end
