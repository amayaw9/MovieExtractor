#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'RMagick'



###################################################
# 参考 【https://gist.github.com/komasaru/6278280】
###################################################

class RGBCaluculator
  # 肌色の16進表記
  FLESH = [ "#F1BB93"[1..2].hex,
            "#F1BB93"[3..4].hex,
            "#F1BB93"[5..6].hex ]

  def initialize(fname)
    @img = Magick::ImageList.new(fname)
    @px_x = @img.columns
    @px_y = @img.rows
    @px_total = @px_x * @px_y
    compile
  end
 
  # 使用色集計
  def compile
    begin
      # 画像の Depth を取得
      img_depth = @img.depth
      # ヒストグラムを取得してハッシュで集計
      @hist = @img.color_histogram.inject({}) {|hash, key_val|
        # 各ピクセルの色を16進で取得
        color = key_val[0].to_color(Magick::AllCompliance, false, img_depth, true)
        hash[color] ||= 0
        hash[color] += key_val[1]
        hash
      }.inject({}) {|hash, key_val|
        # 各色の利用回数から利用率を算出
        k, v = key_val
        hash[k] = (v / @px_total.to_f) * 100
        hash
      }
      @hist.default = 0
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.compile] #{e}"
      exit 1
    end
  end
 
  def hist
    return @hist
  end

  # 肌色スコア算出
  def evalScore
    score = 0
    @hist.each do |color, rate|
      3.times do |i|
        score += rate / (1 + (color[2*i+1,2].hex - FLESH[i]) ** 2)
      end
    end
    return score
  end
end 



# 動画はHDFS /user/`whoami`/tmp/動画ID.mp4
# 中間生成物 key => value = "hadairo" => digest.動画ID.mp4
#            /user/`whoami`/tmp/digest{offset}.動画ID.mp4



# 基準となるスコアの値
SCORE = 10 

ARGF.each {|line|
  line.chomp.split.each do |id|
    # ファイルの所得・静止画の切り出し
    `hadoop fs -get tmp/#{id}.mp4 .`
    `ffmpeg -i #{id}.mp4 -ss 0 -r 1 -vcodec #{id}-%d.jpg`

    # シーン検出・ダイジェスト切り出し
    scenes = `ls #{id}-*.jpg`.split.map {|picture|
      `./Descriptor #{picture}`.split
    }.map {|descripted_pictures|
      descripted_pictures.map {|descripted|
        RGBCaluculator.new(descripted)
      }
    }.each_with_index.map {|objs, index|
      STDERR.puts(score = obj.evalScore())
      score > SCORE ? index : -1
    }.collect {|offset|
      offset >= 0
    }.each {|offset|    
      `ffmpeg -i #{id}.mp4 -ss #{offset} -t 1 -vcodec copy -acodec copy tmp#{id}.mp4`
      `ffmpeg -i tmp#{id}.mp4 -s 280x240 -aspect 4:3 digest#{offset}#{id}.mp4`
      `hadoop fs -put digest#{offset}#{id}.mp4 tmp/digest#{offset}#{id}.mp4`
      `rm -f digest#{offset}#{id}.mp4 tmp#{id}.mp4`
    }
    `rm #{id}*`
    puts "hadairo\t#{id}"
  end
}
