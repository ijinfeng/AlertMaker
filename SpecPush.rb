#! /usr/bin/ruby

class Color
    def self.natural 
        0
    end
    def self.black 
        30 
    end
    def self.red 
        31 
    end
    def self.green 
        32 
    end
    def self.yellow 
        33 
    end
    def self.blue 
        34 
    end
    def self.magenta 
        35 
    end
    def self.cyan 
        36 
    end
    def self.white 
        37 
    end
end

def color_text(text, color = Color.natural)
    if color == 0
        return text
    end
    return "\033[#{color}m#{text}\033[0m"
end


# 拉取最新代码
if system('git pull --rebase origin') == false 
    system('git rebase --abort')
    puts color_text("There is a conflict, please handle it and retry", Color.red)
    return
end


cur_path = Dir.pwd
push_path = cur_path
relate_dir_path = ''
user_custom_version = true
verify_podspec_format = true
pod_repo_name = 'trunk'
pod_repo_source =

# 检查是否存在 SpecPushFile 文件，如果不存在，那么创建
if not File::exist?(cur_path + '/PodPushFile')
    system('touch PodPushFile')
    File.open(cur_path + '/PodPushFile', 'w+') do |f|
        f.write("#写入*.podspec所在的相对目录，不写默认会在脚本执行的目录下查找
PUSH_DIR_PATH=
#是否允许用户自定义版本号，不填或填true将允许用户设置自定义的版本号，而不是自增版本号 
USER_CUSTOM_VERSION=true
#默认开启验证，可以跳过验证阶段
VERIFY_PODSPEC_FORMAT=true
#pod repo的名字，如果是私有库就填私有库的名字
POD_REPO_NAME=trunk
#pod repo的源地址
POD_REPO_SOURCE=https://cdn.cocoapods.org/")
    end
    puts color_text('Create PodPushFile', Color.green) 
end

puts color_text('Parse PodPushFile...', Color.white)
File.open(cur_path + '/PodPushFile') do |f|
    f.each_line do |line|
        key_value = line.split('=')
        key = key_value.first
        value =
        if key_value.count > 1 
            value = key_value.last
        end
        # puts "key=#{key},value=#{value}"
        if key.to_s == 'PUSH_DIR_PATH' and not value.nil?
            relate_dir_path = value.to_s.gsub("\n", '').gsub(' ','').gsub("\t",'')
            push_path = cur_path + '/' + relate_dir_path
            # puts "Find releate dir path=#{relate_dir_path}"
        elsif key.to_s == 'USER_CUSTOM_VERSION' and not value.nil?
            user_custom_version = value
            # puts "Find custom version config=#{user_custom_version}"
        elsif key.to_s == 'VERIFY_PODSPEC_FORMAT' and not value.nil?
            verify_podspec_format = value
        elsif key.to_s == 'POD_REPO_NAME' and not value.nil?
            pod_repo_name = value.to_s
        elsif key.to_s == 'POD_REPO_SOURCE' and not value.nil?
            pod_repo_source = value
        end
    end
end

# puts "Push path is: #{push_path}, relate dir path is: #{relate_dir_path}"

# 搜索podspec路径
podspec_path = ''
find_podspec_reg = relate_dir_path.length == 0 ? '' : (relate_dir_path + '/') + '*.podspec'
# puts "Find podspec reg = #{find_podspec_reg}"
Dir::glob(find_podspec_reg) do |f|
    podspec_path = f
end
if not File::exist?(podspec_path)
    puts color_text "Can't find any podspec file in path: #{podspec_path}, please modify PodPushFile' PUSH_DIR_PATH(key)", Color.red
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

puts color_text("Current version = ", Color.white) + color_text("#{cur_version}", Color.green)

# 允许自定义版本号
if user_custom_version == true
    puts color_text "Please input pod lib's new version, if there is no input or less than or equal old version, it will be incremented:", Color.white
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
        puts color_text "Input invalid version = #{input_version}，will auto +1 in last component", Color.natural
    end
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
                version_coms = version_desc.to_s.split('=')
                if input_valid and user_custom_version
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
                puts color_text("New version = ",Color.white) + color_text("#{new_version}", Color.green)
                write_line = version_coms.first.to_s + '=' + " '#{new_version}'" + "\n"
            end
            t.write write_line  
        end
    end
end

puts color_text("Update version from ",Color.white) + color_text("#{cur_version}",Color.green) + color_text(" to ",Color.white) + color_text("#{new_version}", Color.green)

# 将新数据反写回到原始podspec中
system("cp -f #{temp_podspec_path} #{podspec_path}")
system("rm -f #{temp_podspec_path}")


# 如果本地没有这个repo，那么添加
if system("pod repo | grep #{pod_repo_name}") == false
    puts color_text("Add pod repo named '#{pod_repo_name}' with source: #{pod_repo_source}", Color.white)
    system("pod repo add #{pod_repo_name} #{pod_repo_source}")
end

# 验证podspec格式是否正确
if verify_podspec_format == true
    puts color_text('Start verify podspec...', Color.while)
    if system("pod spec lint #{podspec_path} --allow-warnings") == false
        puts color_text("Podrepo format invalid", Color.red)
        return
    end
end

# 提交代码到远程仓库
puts color_text('Start upload code to remote', Color.white)
system("git commit -am 'update version to #{new_version}'")
system('git push origin')
system("git tag #{new_version}")
system('git push origin --tags')

# 提交pod spec到spec仓库
puts color_text("Start push pod repo to remote '#{pod_repo_name}'", Color.white)
if system("pod repo push #{pod_repo_name} #{podspec_path} --allow-warnings || pod repo push #{pod_repo_name} --allow-warnings --use-libraries") == true 
    puts color_text("Update success ☕️! Current version = #{cur_version}", Color.green)
end

