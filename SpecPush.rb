#! /usr/bin/ruby

require 'yaml'

cur_path = Dir.pwd
push_path = cur_path
relate_dir_path =

# 检查是否存在 SpecPushFile 文件，如果不存在，那么创建
if not File::exist?(cur_path + '/PodPushFile')
    system('touch PodPushFile')
    File.open(cur_path + '/PodPushFile', 'w+') do |f|
        f.write("#写入*.podspec所在的相对目录，不写默认会在脚本执行的目录下查找
        PUSH_DIR_PATH=")
    end
    puts 'Create PodPushFile'
end

File.open(cur_path + '/PodPushFile') do |f|
    f.each_line do |line|
        key_value = line.split('=')
        key = key_value.first
        value =
        if key_value.count > 1 
            value = key_value.last
        end
        puts "key=#{key},value=#{value}"
        if key.to_s == 'PUSH_PATH' and not value.nil?
            relate_dir_path = value.to_s
            push_path = cur_path + relate_dir_path
        end
    end
end

puts "Push path is: #{push_path}, relate dir path is: #{relate_dir_path}"

# 搜索podspec路径
podspec_path = ''
Dir::glob((relate_dir_path.nil? ? '' : (relate_dir_path + '/')) + '*.podspec') do |f|
    podspec_path = f
end
if not File::exist?(podspec_path)
    puts "Can't find any podspec file in path: #{podspec_path}, please modify PodPushFile"
    return 
end

# 在当前podspec目录下新建一个临时 need_delete_temp.podspec 文件
podspec_dir = File.dirname podspec_path
podspec_absolute_path = cur_path + '/' + podspec_path
temp_podspec_path = podspec_dir + '/need_delete_temp.podspec'
temp_podspec_absolute_path = cur_path + '/' + temp_podspec_path

cur_version = ''
# 读取当前podspec文件的版本
File.open(podspec_absolute_path, 'r+') do |f|
    f.each_line do |line|
        # 查找.version
        version_desc = /.*\.version[\s]*=.*/.match line
        if not version_desc.nil?
            cur_version = version_desc.to_s.split('=').last.to_s.gsub("'", '')
            cur_version = cur_version.gsub(' ', '')
            break
        end
    end
end

puts "Current version is = #{cur_version}"

puts "Please input pod lib's new version, if there is no input, it will be incremented:"
input_version = gets.chomp

# 判断输入的version是否>当前的版本号
input_v_s = input_version.to_s.split('.')
cur_v_s = cur_version.split('.')
# 比较的位置，从最左边开始
v_index = 0
# 输入的version是否有效
input_valid = false
while v_index < cur_v_s.count && v_index < input_v_s.count do
    if input_v_s[v_index].to_i > cur_v_s[v_index].to_i
        # 说明用户输入的version比当前的大
        input_valid = true
        break
    elsif input_v_s[v_index].to_i == cur_v_s[v_index].to_i
        v_index += 1
    else
        break
    end
end

if input_valid == false 
    puts "Input invalid version = #{input_version}，will auto +1 in last component"
end

if not File.exist? temp_podspec_absolute_path
    # system("cp -f #{podspec_path} #{temp_podspec_path}")
    system("touch #{temp_podspec_path}")
end

new_version = ''
File.open(temp_podspec_absolute_path, 'r+') do |t|
    File.open(podspec_absolute_path) do |f|
        f.each_line do |line|
            # # 查找.version
            write_line = line
            version_desc = /.*\.version[\s]*=.*/.match line
            if not version_desc.nil?
                puts "======> #{version_desc}"
                version_coms = version_desc.to_s.split('=')
                if input_valid
                    new_version = input_version.to_s
                else
                    version_num = version_coms.last.to_s.gsub("'",'')
                    version_num = version_num.gsub(' ','')
                    v_s = version_num.split('.')
                    # 处理版本号 0.0.1
                    for i in 0...v_s.count do
                        if i == v_s.count - 1 
                            new_version += (v_s[i].to_i + 1).to_s
                        else
                            new_version += (v_s[i].to_s + '.')
                        end
                    end
                end
                puts "New version = #{new_version}"
                write_line = version_coms.first.to_s + '=' + " '#{new_version}'" + "\n"
            end
            t.write write_line  
        end
    end
end

puts "Update version frome #{cur_version} to #{new_version}"

# 将新数据反写回到原始podspec中
system("cp -f #{temp_podspec_path} #{podspec_path}")
system("rm -f #{temp_podspec_path}")