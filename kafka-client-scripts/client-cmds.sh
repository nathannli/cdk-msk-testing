# https://docs.aws.amazon.com/msk/latest/developerguide/getting-started.html

home_loc="/home/ec2-user"
topic_name="MSKTutorialTopic"

# install java
sudo yum -y install java-11

# download kafka quickstart
msk_version=3.7.1
wget "https://archive.apache.org/dist/kafka/${msk_version}/kafka_2.13-${msk_version}.tgz" -O "${home_loc}/kafka_2.13-${msk_version}.tgz"

# extract
tar -xzf "${home_loc}/kafka_2.13-${msk_version}.tgz"

# add the aws iam jar
wget "https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.1/aws-msk-iam-auth-1.1.1-all.jar" -O "${home_loc}/kafka_2.13-${msk_version}/libs/aws-msk-iam-auth-1.1.1-all.jar"

# add client.properties file into the bin folder
cat << EOF > "${home_loc}/kafka_2.13-${msk_version}/bin/client.properties"
security.protocol=PLAINTEXT
EOF

# bootstrap server
cluster_arn=$(aws kafka list-clusters --output text --query 'ClusterInfoList[*].ClusterArn')
bootstrap_server=$(aws kafka get-bootstrap-brokers --cluster-arn $cluster_arn --output text)

# create topic
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-topics.sh" --create --bootstrap-server $bootstrap_server --command-config "${home_loc}/kafka_2.13-${msk_version}/bin/client.properties" --replication-factor 2 --partitions 1 --topic $topic_name

# open consumer
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-console-consumer.sh" --bootstrap-server $bootstrap_server --topic $topic_name --from-beginning --consumer.config "${home_loc}/kafka_2.13-${msk_version}/bin/client.properties"

# open producer
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-console-producer.sh" --broker-list $bootstrap_server --producer.config "${home_loc}/kafka_2.13-${msk_version}/bin/client.properties" --topic $topic_name