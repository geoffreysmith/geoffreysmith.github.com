###
# Blog settings
###

# Time.zone = "UTC"

activate :syntax

activate :blog do |blog|
  # blog.prefix = "blog"
  blog.permalink = ":title.html"
  blog.sources = "posts/:year-:month-:day-:title.html"
  # blog.taglink = "tags/:tag.html"
  blog.layout = "post"
  blog.summary_separator = /READMORE/
  blog.summary_length = 500
  # blog.year_link = ":year.html"
  # blog.month_link = ":year/:month.html"
  # blog.day_link = ":year/:month/:day.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # blog.paginate = true
  # blog.per_page = 1
  # blog.page_link = "page/:num"
end

page "/feed.xml", :layout => false

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :cache_buster
  # activate :relative_assets
  # set :http_path, "/Content/images/"
end
