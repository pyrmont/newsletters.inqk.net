# frozen_string_literal: true

require "feedstock"
require "timeliness"

class NytTopicsJapan
  def data
    url = "https://www.nytimes.com/svc/collections/v1/publish/https://www.nytimes.com/topic/destination/japan/rss.xml"

    info = { subject: { literal: "Japan - New York Times Topics" },
             template: { literal: "d-33aeb0cdbf80445f8e601ece0578a2a2" } }

    entries = { path: "item",
                filter: lambda { |entry| keep? entry } }

    entry = { title: "title",
              link: "link",
              date: { path: "pubDate",
                      processor: lambda { |content, rule| format_date content } },
              byline: "dc|creator",
              summary: "description" }

    rules = { info: info, entries: entries, entry: entry }

    Feedstock.data url, rules, :xml
  end

  def format_date(date)
    published = Timeliness.parse date, :date
    published.strftime("%d %B %Y")
  end

  def keep?(entry)
    now = Time.now
    published = Timeliness.parse entry["date"], :date
    (now - published) < (24 * 60 * 60)
  end
end
