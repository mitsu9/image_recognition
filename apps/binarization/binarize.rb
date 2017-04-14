require 'opencv'
include OpenCV

# 2値化する
def binarize(file, t)
  image = CvMat.load(file)
  gray_img = image.BGR2GRAY
  bin_img = gray_img.threshold(t.to_i, 255, :binary)
end

# 判別分析法（大津の2値化）
def discriminant(file)
  image = CvMat.load(file)
  gray_img = image.BGR2GRAY
  hist = histogram(gray_img)
  eval_value, best_t = 0, 0
  (0...255).each{ |t|
    # t := 閾値
    # w1(w2) := 左側(右側)の画素数
    # m1(m2) := 左側(右側)の平均
    w1, w2 = 0, 0
    m1, m2 = 0, 0

    w1 = hist[0..t].reduce(:+)
    m1 = hist[0..t].map.with_index {|n, idx| n * idx}.reduce(:+)/w1 rescue 0

    w2 = hist[t+1..255].reduce(:+)
    m2 = hist[t+1..255].map.with_index(t+1) {|n, idx| n * idx}.reduce(:+)/w2 rescue 0

    e = w1 * w2 * (m1 - m2) ** 2
    if eval_value < e
      eval_value = e
      best_t = t
    end
  }
  best_t
end

def histogram(gray_img)
  hist = Array.new(256, 0)
  [*0...gray_img.rows].product([*0...gray_img.cols]).each{ |(y, x)|
    b = gray_img.at(y, x)
    hist[b[0]] += 1
  }
  hist
end

# 微分ヒストグラム法
def diff_histogram(file)
  200
end

def show_image(image, t)
  window = GUI::Window.new("binarize by #{t}")
  window.show(image)
end

# main
file = ARGV[0]

# 元の画像の表示
image = CvMat.load(file)
# GUI::Window.new("Original Image").show(image)
# GUI::Window.new("Gray-scale Image").show(image.BGR2GRAY)

# tを様々な方法で計算する
t_dis = discriminant(file)
t_diff = diff_histogram(file)

# 2値化の実行
img_dis = binarize(file, t_dis)
img_diff = binarize(file, t_diff)

# 表示
show_image(img_dis, t_dis)
# show_image(img_diff, t_diff)
GUI::wait_key
