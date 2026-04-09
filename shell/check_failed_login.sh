#!/bin/bash
#how many times the people  try to connect to my server but failed 
awk '/Failed password/{ip[$11]++}END{for (i in ip){print i,ip[i]}}'  /var/log/secure   
