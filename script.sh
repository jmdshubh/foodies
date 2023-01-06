                sudo apt update -y
                sudo apt install -y openjdk-11-jdk
                CHECK_USR_tomcat=$(grep tomcat /etc/passwd | wc -l)
                echo $CHECK_USR_tomcat
                if [ $CHECK_USR_tomcat -eq 0 ]
                then
                    sudo useradd -m -s /bin/bash tomcat
                    echo "tomcat user created"
                    sudo mkdir -p /u01/middleware
                    sudo chown tomcat:tomcat -R /u01/middleware
                else
                    echo "tomcat user is already here"
                fi
                sudo su tomcat -c 'wget "https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.70/bin/apache-tomcat-9.0.70.tar.gz" -P /u01/middleware/'
                sudo su tomcat -c "tar -xzvf /u01/middleware/apache-tomcat-9.0.70.tar.gz -C /u01/middleware "
                sudo cp tomcatservicetemplate  /etc/systemd/system/tomcat.service
                JPATH=$(readlink -f $(which java) | cut -b 35-45 --complement)
                sudo sed -i "s|#JAVA_HOME#|$JPATH|g" /etc/systemd/system/tomcat.service
                sudo sed -i "s|#TOMCAT_HOME_DIR#|$TOMCAT_HOME_DIR|g"  /etc/systemd/system/tomcat.service
                sudo sed -i "s|#TOMCAT_USER#|tomcat|g"  /etc/systemd/system/tomcat.service 
                sudo sed -i "s|#TOMCAT_GROUP#|tomcat|g"  /etc/systemd/system/tomcat.service 
                sudo systemctl daemon-reload
                sudo systemctl enable tomcat
                sudo systemctl start tomcat
                sudo cp /u01/jenkins/workspace/foodiespipeline/target/ foodies.war '$TOMCAT_HOME_DIR'/webapps/
                sudo chown tomcat:tomcat -R '$TOMCAT_HOME_DIR'/webapps
                sudo systemctl restart tomcat
                sudo su tomcat -c "cat '$TOMCAT_HOME_DIR'/logs/catalina.out"