# https://ls-170-book-viewer.herokuapp.com/ => link to completed app for reference
require 'tilt/erubis' # => interface over Ruby template engines
require "sinatra"
require "sinatra/reloader"
require 'pry'

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(content)
    content.split("\n\n").each_with_index.map do |line, index|
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end

  def highlight(content, query)
    content.gsub(query, "<strong>#{query}</strong>" )
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read "data/chp#{number}.txt"
  erb :chapter
end

get "/search" do
  if params[:query]
    @results = @contents.each_with_index.each_with_object([]) do |(chapter, index), results|
      text = File.read("data/chp#{index + 1}.txt")
      paragraphs = text.split("\n\n")
      paragraphs.each_with_index do |paragraph, paragraph_index|
        if paragraph.include? params[:query]
          results << [chapter, index, paragraph, paragraph_index]
        end
      end
    end
  end
  erb :search
end

not_found do
  redirect "/"
end
