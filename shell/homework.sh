#!/bin/bash
# 1. 执行脚本输出提示用户选择菜单如下:
#   1) shell 常用命令
#   2) 石头剪刀布
#   3) 加减乘除计算器
#   4) 学生成绩管理系统
# 2. 以上信息包含4个功能，通过函数实现，函数分别取名:
#   shell_commands
#   shell_stonegam
#   shell_calculator
#   student_score
# 3. 用户输入数字,具体实现要求如下
#   用户输入1, 调用函数shell_commands, 分类打印常用的shell命令
#   用户输入2, 调用函数shell_stonegam, 进入剪刀石头布游戏
#   用户输入3, 调用函数shell_calculator, 实现一个加减乘除计算器
#   用户输入4, 调用函数student_score, 实现一个学生成绩管理系统
#

function shel_commands(){
  echo  '这是shell_commands 函数, 分类打印常用shell命令'
  echo -e '用户及群组管理命令:\n
  useradd   新增用户
  userdel   删除用户
  usermod   用户profile修改
  groupadd  新增组
  groupdel  删除组
  groupmod  组profile修改
  groupmems 组成员管理
   '

  echo -e '文件管理命令:\n
  pwd 查看当前位置
  ls  查看目录下的文件
  cd  前往特定目录
  rm  删除文件或目录
  mkdir 创建目录
  touch 创建空文件
  chmod 文件权限管理
  chown 文件所有人/组管理
  vim 文件编辑器
  '

}

function shell_stonegame(){
  echo '剪刀石头布'

}

function shell_calculattor(){
  echo '计算机'
}

function student_score(){
  echo '学生成绩管理系统'
}
while true
do
  read -p  '请选择功能  ' function
  case ${function} in
  1)
  echo '1'
    ;;
  2)
  echo '2'
    ;;
  3)
  echo '3'
    ;;
  4)
  echo '3'
    ;;

  esac

  read -p 'exit or continue ' Code
  if [ ${Code} == 'exit' ];then
    break
  elif [ ${Code} != 'exit' ] && [ ${Code} != 'continue' ];then
    echo  -e '\033[35m please input exit or continue \033[039m'
  else
    continue
  fi

done

