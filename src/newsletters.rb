# frozen_string_literal: true

require "json"
require "sendgrid-ruby"
require "timeliness"

include SendGrid

Timeliness.add_formats(:date, "mmm d, yy")

def post(data)
  return if data[:entries].empty?
  data[:info].merge! JSON.load_file("settings.json")
  template = ERB.new File.read("payload.json"), trim_mode: "-"
  json = template.result_with_hash info: data[:info], entries: data[:entries]
  sg = SendGrid::API.new(api_key: data[:info]["api_key"])
  begin
    sg.client.mail._("send").post(request_body: JSON.parse(json))
  rescue Exception => e
    puts e.message
  end
end

def file_names
  all = Dir.each_child("input").map { |fn| fn.prepend "input/" }

  if ARGV.empty?
    all
  elsif ARGV[0] != "-e"
    ARGV.each
  else
    excluded = ARGV.slice(1..-1)
    all.reject { |fn| excluded.include? fn }
  end
end

file_names.each do |file_name|
  require_relative file_name
  base_name = file_name.split("/").last.delete_suffix(".rb")
  class_name = base_name
    .split('_')
    .map(&:capitalize)
    .join
  stock = Object.const_get(class_name).new
  post stock.data
end
