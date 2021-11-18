#!/usr/bin/ruby -w
# -*- encoding: utf-8 -*-

=begin
  第一步
    这个脚本主要负责解析本地包管理器的数据库记录，得到如下信息：
      1. 当前已安装的包及其版本
      2. 系统中要求的包列表及其版本
    根据上述两个信息，检测系统中是否存在一些不合理的依赖问题(事实上这是不可能的 ^_^)
=end

BEGIN {
  $package_manager = ""                                         # 本地使用的包管理器类型
  $local_packages = Hash.new                                    # 保存本地包及其版本信息
  $local_packages_and_dependency = Hash.new                     # 保存本地包及其依赖包信息
}


=begin
  判断当前系统有那种包管理器
    - pacman
=end
def get_package_manager()
  manager = Array["pacman", "dpkg"]
  path = ENV['PATH'].split(":")

  for m in manager
    for dir in path do
      t = dir + "/" + m
      if File::exist?(t) then
        case m
        when "dpkg"     then ($package_manager = m; break) if File::exist?("/var/lib/dpkg/")
        when "pacman"   then ($package_manager = m; break) if File::exist?("/var/lib/pacman/local/")
        end
      end
    end
    break if ("" != $package_manager)
  end

  (puts "暂时不支持您系统的包管理器!"; exit) if ($package_manager == "") 
end


=begin
  读取 arch 软件包信息
=end
def get_package_info_pacman()
  path = "/var/lib/pacman/local/"
  (puts "包管理器数据库 '/var/lib/pacman/local' 不存在!"; exit) if not File::exist?(path)

  # 遍历所有包信息
  dir = Dir::open(path)
  for n in dir
    file = path + "/" + n + "/desc"
    if File::exist?(file) then
      flag = true
      l = ""
      @name = ""
      @version = ""
      @source = ""
      @depends = Array.new

      fr = IO.readlines (file)
      for line in fr
        if line.strip.eql?("")          then l = ""
        elsif line.strip[0].eql?("\\n") then l = ""
        elsif line.strip[0].eql?("\%")  then l = line.strip
        else
          if l.eql?("\%NAME\%")         then l = "" ; @name = line.strip;
          elsif l.eql?("\%VERSION\%")   then l = "" ; @version = line.strip
          elsif l.eql?("\%BASE\%")      then l = "" ; @source = line.strip
          elsif l.eql?("\%DEPENDS\%")   then (@depends << line.strip) if not line.strip.eql?("")
          end
        end
      end

      puts "name:    #{@name}"
      puts "version: #{@version}"
      puts "source:  #{@source}"
      puts "depends: #{@depends}"
      puts "\n\n"
    end
  end


end


END {

}



### main ###
get_package_manager

puts "本地包管理器是:#{$package_manager}"

case $package_manager
when "pacman"   then get_package_info_pacman
end


