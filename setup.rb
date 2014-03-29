#!/usr/bin/ruby
# -*- coding: utf-8 -*-

if ARGV.length != 1
  exit 1
end
x = ARGV.at(0).to_i
file = open("input", "w+")
(1..x).to_a.each do |i|
  `cp backup/nico.mp4 video/nico#{i}.mp4`
  `cp backup/nico.jpg video/nico#{i}.jpg`
  file.printf "%d%s", i, (i % 5 == 0 ? "\n" : " ")
end

STDERR.puts `hadoop fs -rmr tmp`
STDERR.puts `hadoop fs -mkdir tmp`

`ls video`.split.each {|f|
  STDERR.puts `hadoop fs -put video/#{f} tmp/#{f}`
}
