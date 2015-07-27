require 'sinatra'
require 'nokogiri'
require 'open-uri'

get '/' do
  city_links = cities.map { |c| "<a href='/#{c.values[0]}'>#{c.keys[0]}</a>" }.join(' | ')
  "If you are 18 or older, you can give up and start over in: <br>#{city_links}"
end

get '/:city' do
  city = params[:city]
  go_back + find_house(city) + "<p></p>" + find_love(city) + "<p></p>" + find_job(city)
end

def cities
  cities_page = Nokogiri::HTML(open('https://geo.craigslist.org/iso/us'))
  cities_page.css('div#postingbody li a').map do |c|
    { c.text => c['href'].match(%r{^http://(.+?)\..*}).captures[0] }
  end
end

def go_back
  "<a href='/'><-- give up and start over again</a><p></p>"
end

def find_house(city)
  apt_page = most_recent_post(city, 'apa')

  image = apt_page.css('section.userbody img')[0]['src']
  "you will live here <br><img src='#{image}'>"
end

def find_love(city)
  love_types = [{ 'she' => 'w4w' }, { 'she' => 'w4m' }, { 'he' => 'm4w' }, { 'he' => 'm4m' }]
  type = love_types.sample
  personals_page = most_recent_post(city, type.values[0])

  image = personals_page.css('section.userbody img')[0]['src']
  "#{type.keys[0]} will love you <br><img src='#{image}'>"
end

def find_job(city)
  job_page = most_recent_post(city, 'jjj')

  job_text = job_page.css('section#postingbody')[0].text.split("\n")[0..3].join("\n")
  "you will work here <br><table border='2'><tr><td>#{job_text}</td></tr></table>"
end

def most_recent_post(city, category)
  index_page = Nokogiri::HTML(open("http://#{city}.craigslist.org/search/#{category}?hasPic=1"))
  url = "http://#{city}.craigslist.org/" + index_page.css('p.row a')[0]['href']
  Nokogiri::HTML(open(url))
end
