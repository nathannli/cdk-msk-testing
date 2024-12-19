# https://docs.aws.amazon.com/msk/latest/developerguide/getting-started.html

home_loc="/home/ubuntu/nathan"
home_loc="/home/ec2-user"
topic_name="MSKTutorialTopic"
topic_name="prod_tx0"
msk_version=3.7.1
bootstrap_server="b-2.cdkmskcluster.duzbvi.c6.kafka.us-east-1.amazonaws.com:9092,b-1.cdkmskcluster.duzbvi.c6.kafka.us-east-1.amazonaws.com:9092"
# bootstrap server
cluster_arn=$(aws kafka list-clusters --output text --query 'ClusterInfoList[*].ClusterArn')
bootstrap_server=$(aws kafka get-bootstrap-brokers --cluster-arn $cluster_arn --output text)

# install java
sudo yum -y install java-11

# download kafka quickstart
wget "https://archive.apache.org/dist/kafka/${msk_version}/kafka_2.13-${msk_version}.tgz" -O "${home_loc}/kafka_2.13-${msk_version}.tgz"

# extract
tar -xzf "${home_loc}/kafka_2.13-${msk_version}.tgz"

# add the aws iam jar
wget "https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.1/aws-msk-iam-auth-1.1.1-all.jar" -O "${home_loc}/kafka_2.13-${msk_version}/libs/aws-msk-iam-auth-1.1.1-all.jar"

# add client.properties file into the bin folder
cat << EOF > "${home_loc}/kafka_2.13-${msk_version}/bin/client.properties"
security.protocol=PLAINTEXT
EOF

# create topic
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-topics.sh" --create --bootstrap-server $bootstrap_server --command-config "${home_loc}/kafka_2.13-${msk_version}/bin/client.properties" --replication-factor 2 --partitions 1 --topic $topic_name

# open consumer
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-console-consumer.sh" --bootstrap-server $bootstrap_server --topic $topic_name --from-beginning --consumer.config "${home_loc}/kafka_2.13-${msk_version}/bin/client.properties"
sh "/home/ec2-user/kafka_2.13-${msk_version}/bin/kafka-console-consumer.sh" --bootstrap-server $bootstrap_server --topic $topic_name --from-beginning --consumer.config "/home/ec2-user/kafka_2.13-${msk_version}/bin/client.properties"
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-console-consumer.sh" --bootstrap-server $bootstrap_server --topic quickstart-events --from-beginning --consumer.config "${home_loc}/kafka_2.13-${msk_version}/bin/client.properties"



# open producer
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-console-producer.sh" --broker-list $bootstrap_server --producer.config "${home_loc}/kafka_2.13-${msk_version}/bin/client.properties" --topic $topic_name

# list topics
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-topics.sh" --list --bootstrap-server $bootstrap_server

# list details of a specific topic
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-topics.sh" --describe --topic $topic_name --bootstrap-server $bootstrap_server

# alter topic partition count (currently there are 4 brokers) to equal number of brokers
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-topics.sh" --bootstrap-server $bootstrap_server --alter --topic $topic_name  --partitions 4

# apply reassignment plan
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-reassign-partitions.sh" --bootstrap-server $bootstrap_server --execute --reassignment-json-file "${home_loc}/reassignment-plan.json"

# check reassignment progress
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-reassign-partitions.sh" --bootstrap-server $bootstrap_server --verify --reassignment-json-file "${home_loc}/reassignment-plan.json"


# force leader re-election
sh "${home_loc}/kafka_2.13-${msk_version}/bin/kafka-leader-election.sh" --bootstrap-server $bootstrap_server --all-topic-partitions --election-type preferred



# run kafka_producer.Producer test
java -cp tx-kafka-2.0.1-jar-with-dependencies_nathan.jar com.sabio.kafka_producer.Producer myuniquetransactionid MSKTutorialTopic test b-2.cdkmskcluster.duzbvi.c6.kafka.us-east-1.amazonaws.com:9092,b-1.cdkmskcluster.duzbvi.c6.kafka.us-east-1.amazonaws.com:9092 1700000000000


java -cp tx-kafka-2.0.1-jar-with-dependencies.jar com.sabio.kafka_producer.Producer myuniquetransactionid quickstart-events test b-2.cdkmskcluster.duzbvi.c6.kafka.us-east-1.amazonaws.com:9092,b-1.cdkmskcluster.duzbvi.c6.kafka.us-east-1.amazonaws.com:9092