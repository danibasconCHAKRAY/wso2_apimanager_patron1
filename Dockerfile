FROM ubuntu:latest

RUN apt update && /
	apt install -y openjdk-8-jdk && \
	apt install -y vim && \
	apt install -y wget && \
	apt install -y unzip && \
	apt clean && \
	rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/wso2/product-apim/releases/download/v2.5.0/wso2am-2.5.0.zip && \
	unzip wso2am-2.5.0.zip -d /home/ && \
	rm -r wso2am-2.5.0.zip

#RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.47.zip && \
#	unzip mysql-connector-java-5.1.47.zip

#RUN wget http://www.java2s.com/Code/JarDownload/sqljdbc4/sqljdbc4-2.0.jar.zip && \
#	unzip sqljdbc4-2.0.jar.zip

#RUN wget https://netix.dl.sourceforge.net/project/webolab/0.9/lib/ojdbc14.jar
