#!/bin/bash
usr_info=/opt/userinfo.dat
# username   password
check_info=/opt/check.dat
# username time sign_out/sign_in  late/ontime
if [ ! -f ${usr_info} ];then
    echo "username   password"  > ${usr_info}
fi
if [ ! -f ${check_info} ];then
    echo -e "username\ttime\tsign_out/sign_in\tlate/ontime\t"  >  ${check_info}
fi


function validation {

#check if there is a valid user in usr_info
read -p "please input your username "  user_input
usr_in_dat=`grep ${user_input}  ${usr_info} | awk '{print $1}' `
if [ -z ${usr_in_dat} ];then  # validate username
  echo "user not exist"
  exit 0
else
read -p "please input your password"  -s password
echo ""
passwd_in_dat=`grep ${user_input} ${usr_info} | awk '{print $2}' `
  if [ ${password} != ${passwd_in_dat} ];then   # validate password
    echo "wrong password"
    exit 0
  else
    echo "login successfully "
  fi
fi

}

function  sign_in {
Current_time=`date +%H%M`

if [ ${Current_time} -gt 0800 ];then
  echo "${user_input}  signin  sign_in_time:${Current_time}  late" >> ${check_info}
else
  echo "${user_input}  signin  sign_in_time:${Current_time}  ontime" >> ${check_info}
fi
}

function sign_out {
Current_time=`date +%H%M`

if [ ${Current_time} -lt 1800 ];then
  echo "${user_input}  signout  sign_out_time:${Current_time}  early" >> ${check_info}
else
  echo "${user_input}  signout  sign_out_time:${Current_time}  ontime" >> ${check_info}
fi
}

function query {
    egrep "early|late" ${check_info} | grep ${user_input}
}

function calculation {
    echo "+++++++++++++++++++++++calculation+++++++++++++++++++++++"
    sign_in_total=`grep "signin" ${check_info} | wc -l`
    sign_out_total=`grep "signout" ${check_info} | wc -l`
    normal_sign_in_total=`grep "signin" ${check_info} | grep "ontime" | wc -l`
    normal_sign_out_total=`grep "signout"  ${check_info} | grep "ontime" | wc -l`

    normal_sign_in_rate=`echo "scale=2;${normal_sign_in_total}/${sign_in_total} * 100" |bc`
    normal_sign_out_rate=`echo "scale=2;${normal_sign_out_total}/${sign_out_total} * 100" |bc`

    echo "normal sign_in rate is ${normal_sign_in_rate} %"
    echo "normal sign_out rate is ${normal_sign_out_rate} %"
    echo "+++++++++++++++++++++++calculation+++++++++++++++++++++++"
}

echo "validation , please input your info"
validation

while true;do

    echo "================================"
    echo "Attendance System - Main Menu"
    echo "1. Sign-in"
    echo "2. Sign-out"
    echo "3. View Absence Information"
    echo "4. Calculate Attendance Rate"
    echo "5. Exit"

  read -p 'please input the corresponding code '  input_code
  case ${input_code} in

  1)
    sign_in
    ;;
  2)
    sign_out
    ;;
  3)
    query
    ;;
  4)
    calculation
    ;;
  5)
    echo "Exiting program. Goodbye!"
    exit 0
    ;;
  *)
    echo "invalid input ,please input correct input_code"
    ;;
  esac
  
done