#!/bin/bash

dt=`date`
webserverpriv=172.31.82.203
webserverpub=54.172.140.241

response=`curl -o /dev/null -s -w "%{http_code}\n" http://$webserverpub:81/`
echo $response

if [ $response == 200 ]
then
        echo 'Web Server is working fine'

else
        echo $dt************** >> /tmp/checker.log
        echo 'Web Server did not respond with a 200' | tee -a /tmp/checker.log
        echo 'Remotely starting nginx...' | tee -a /tmp/checker.log
        ssh ec2-user@$webserverpriv 'sudo systemctl restart nginx; sudo systemctl status nginx' | tee -a /tmp/checker.log

fi
