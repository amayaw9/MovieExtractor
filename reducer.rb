#!/usr/bin/ruby
# -*- coding: utf-8 -*-


`touch output.mp4`
ARGF.each do |line|
  key, value = line.chomp.split(/\t/)
  if key == "hadairo"
    `hadoop fs -get tmp/digest*#{value}.mp4 .`
    `ls digest*#{value}.mp4`.split.each {|digest|
      # HDFSからファイルを取得
      `hadoop fs -get tmp/#{digest} .`
      # 動画の結合
      if system "ls output.mp4"
        `MP4Box -cat #{digest} output.mp4`
      else
        `mv #{digest} output.mp4`
      end
    end
  end
end

`hadoop fs -put ./output.mp4 tmp/output.mp4`
`rm -f digest*`
`rm -f output.mp4`

# 空の標準出力
puts ""
