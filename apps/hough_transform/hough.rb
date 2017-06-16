require 'opencv'
include OpenCV

########################
## ハフ変換のパラメータ  ##
########################
#
## hough_lines(CV_HOUGH_STANDARD, rho, theta, threshold, 0, 0)
# double rho : ピクセル単位で表される距離分解能。
# double theta : ラジアン単位で表される角度分解能。
# int threshold : 閾値パラメータ．十分なヒット数（> threshold）を得た直線のみが出力されます。
#
## hough_lines(CV_HOUGH_PROBABILISTIC, rho, theta, threshold, minLineLength, maxLineGap)
# double rho : ピクセル単位で表される距離分解能。
# double theta : ラジアン単位で表される角度分解能。
# int threshold : 閾値パラメータ．十分なヒット数（> threshold）を得た直線のみが出力されます。
# double minLineLength : 最小の線分長．これより短い線分は棄却されます。
# double maxLineGap : 2点が同一線分上にあると見なす場合に許容される最大距離。
#
# 参考: https://github.com/ruby-opencv/ruby-opencv/blob/76a076d8a377a0989cc3323e1ba9e87ebaa21c74/ext/opencv/cvmat.cpp#L5003

# ハフ変換
def hough_standard(img)
  gry = img.BGR2GRAY
  result = gry.GRAY2BGR
  lines = gry.canny(50,200,3).hough_lines(CV_HOUGH_STANDARD, 1, Math::PI/180, 50, 0, 0) # エッジ検出をしてから計算
  cnt = 200 # 全て表示すると多すぎるので数を指定する
  lines.each do |l|
    cos, sin = Math::cos(l.theta), Math::sin(l.theta)
    x0, y0 = l.rho*cos,l.rho*sin
    result.line!(CvPoint.new(x0-1000*sin,y0+1000*cos), CvPoint.new(x0+1000*sin,y0-1000*cos),{:color=>CvColor::Red,:thickness=>1})
    cnt -= 1
    break if cnt < 0
  end
  result
end

# 確率的ハフ変換
def hough_probabilistic(img)
  gry = img.BGR2GRAY
  result = gry.GRAY2BGR
  lines = gry.canny(50,200,3).hough_lines(CV_HOUGH_PROBABILISTIC, 1, Math::PI/180, 50, 50, 10)
  lines.each do |l|
    result.line!(l.point1, l.point2, {:color=>CvColor::Red,:thickness=>1})
  end
  result
end

# main
file = ARGV[0]

image = CvMat.load(file)
hough_standard = hough_standard(image)
hough_probabilistic = hough_probabilistic(image)

GUI::Window.new("Original Image").show(image)
GUI::Window.new("Canny").show(image.BGR2GRAY.canny(50,200,3))
GUI::Window.new("Hough Transform (standard)").show(hough_standard)
GUI::Window.new("Hough Transform (probabilistic)").show(hough_probabilistic)
GUI::wait_key
