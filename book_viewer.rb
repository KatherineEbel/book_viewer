require "sinatra"
require "sinatra/reloader" if development?
require 'tilt/erubis'

before do
  @contents = File.readlines('data/toc.txt')
end


helpers do
  def in_paragraphs(text)
    paragraphs(text).map.with_index { |p, i| "<p id='p-#{i}'>#{p}</p>" }.join
  end

  def highlight(text, query)
    text.gsub(query, "<strong>#{query}</strong>")
  end
end

def paragraphs(text)
  text.split("\n\n")
end

def read(chapter)
  File.read("data/chp#{chapter}.txt")
end

def chapters
  @contents.map.with_index { |c, i| { title: c, number: i + 1, content: read(i + 1) }}
end

def search_result(chapter, query)
  paragraphs = chapter[:content].split("\n\n")
  links = paragraphs.select { |p| p.include? query }
               .map do |p|
    "<li><a href=\"/chapters/#{chapter[:number]}#p-#{paragraphs.index(p)}\">#{p}</a></li>"
  end.join
  "<li><h2>#{chapter[:title]}</h2><ul>#{links}</ul></li>"
end

def matching_chapters(query)
  return unless query
  chapters.select { |c| c[:content].include?(query) }
          .map { |c| search_result(c, query) }.join
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  @number = params['number'].to_i
  redirect "/" unless (1..@contents.size).cover? @number

  @title = "Chapter #{@number} | #{@contents.at(@number - 1)}"
  @chapter = read(@number)
  erb :chapter
end

get "/search" do
  if params['query']
    @results = matching_chapters(params['query'])
  end
  erb :search
end

post '/search' do
end

not_found do
  redirect "/"
end
