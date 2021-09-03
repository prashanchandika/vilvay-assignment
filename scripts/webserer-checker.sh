#!/bin/bash

dt=`date`
webserverpriv=172.31.87.161
webserverpub=52.90.71.49

response=`curl -o /dev/null -s -w "%{http_code}\n" http://$webserverpub:81/`
echo $response

if [ $response == 200 ]
then
	echo 'Web Server is working fine'

else
	echo $dt************** >> /tmp/checker.log
	echo 'Web Server did not respond with a 200' >> /tmp/checker.log
	echo 'Remotely starting nginx...' >> /tmp/checker.log
	ssh ec2-user@$webserverpriv 'sudo systemctl restart nginx; sudo systemctl status nginx' >> /tmp/checker.log

fi
