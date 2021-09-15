#! /usr/bin/env ruby

require 'open3'
require 'csv'

def next_bookmark_line f
  line = f.readline while line !~ /^Bookmark/
  return line
end

csv = CSV.new(STDOUT, 
        write_headers: true, 
        headers: ['title', 'level', 'file', 'page'])

ARGV.each do |n|
  Open3.popen2('pdftk', n, 'dump_data_utf8') do |stdin, stdout, wait_thr|
    until stdout.eof? do
      begin
        line = next_bookmark_line stdout
        if line =~ /BookmarkBegin/
          line = next_bookmark_line stdout
          if line =~ /BookmarkTitle/
            title = line.split[1..].join(' ')
            line = next_bookmark_line stdout
            if line =~ /BookmarkLevel/
              level = line.split[1]
              line = next_bookmark_line stdout
              if line =~ /BookmarkPageNumber/
                page = line.split[1]

                csv << [title, level, n, page]
              end
            end
          end
        end
      rescue EOFError
      end
    end
  end
end
