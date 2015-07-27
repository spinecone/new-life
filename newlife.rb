require 'sinatra'
require 'nokogiri'
require 'open-uri'

get '/' do
  city_links = cities.map { |c| "<a href='/#{c[:path]}'>#{c[:title]}</a>" }.join(' | ')
  "If you are 18 or older, you can give up and start over in: <br>#{city_links}"
end

get '/:city' do
  city = params[:city]
  [
    go_back,
    welcome(city),
    find_house(city),
    find_love(city),
    find_job(city)
  ].join('<p></p>')
end

def cities
  cities_page = Nokogiri::HTML(open('https://geo.craigslist.org/iso/us'))
  cities_page.css('div#postingbody li a').map do |c|
    { title: c.text, path: c['href'].match(%r{^http://(.+?)\..*}).captures[0] }
  end
end

def go_back
  "<a href='/'><-- give up and start over again</a><p></p>"
end

def welcome(city)
  city_title = cities.select { |c| c[:path] == city }.first[:title]
  "~*~*~*WELCOME TO #{city_title.upcase}*~*~*~"
end

def find_house(city)
  apt_page = most_recent_post(city, 'apa')

  image = apt_page[:page].css('section.userbody img')[0]['src']
  link = "<a href='#{apt_page[:url]}'>#{apt_page[:url]}</a>"
  "you will live here <br><img src='#{image}'><br>#{link}"
end

def find_love(city)
  love_types = [
    { pronoun: 'she',  path: 'w4w' },
    { pronoun: 'she', path: 'w4m' },
    { pronoun: 'he', path: 'm4w' }
  ]
  type = love_types.sample
  personals_page = most_recent_post(city, type[:path])
  image = personals_page[:page].css('section.userbody img')[0]['src']
  link = "<a href='#{personals_page[:url]}'>#{personals_page[:url]}</a>"
  "#{type[:pronoun]} will love you <br><img src='#{image}'><br>#{link}"
end

def find_job(city)
  job_page = most_recent_post(city, 'jjj')

  job_text = job_page[:page].css('section#postingbody')[0].text.split("\n")[0..3].join("\n")
  link = "<a href='#{job_page[:url]}'>#{job_page[:url]}</a>"
  "you will work here <br><table border='2'><tr><td>#{job_text}</td></tr></table>#{link}"
end

def most_recent_post(city, category)
  index_page = Nokogiri::HTML(open("http://#{city}.craigslist.org/search/#{category}?hasPic=1"))
  url = "http://#{city}.craigslist.org" + index_page.css('p.row a')[0]['href']
  page = Nokogiri::HTML(open(url))
  { url: url, page: page }
end
