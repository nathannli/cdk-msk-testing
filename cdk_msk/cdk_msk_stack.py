from aws_cdk import (
    # Duration,
    Stack,
    # aws_sqs as sqs,
    aws_msk as msk

)
from constructs import Construct


class CdkMskStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # The code that defines your stack goes here

        msk_cluster = msk.CfnCluster(
            self, "CdkMskCluster",
            cluster_name="cdk-msk-cluster",
            kafka_version="3.7.x.kraft",
            number_of_broker_nodes=2,
            broker_node_group_info=msk.CfnCluster.BrokerNodeGroupInfoProperty(
                client_subnets=["subnet-07dbb22503860d099", "subnet-f97fccd7"],
                instance_type="kafka.m7g.large",
                security_groups=["sg-4d45ea07"],
            ),
            client_authentication=msk.CfnCluster.ClientAuthenticationProperty(
                sasl=msk.CfnCluster.SaslProperty(
                    iam=msk.CfnCluster.IamProperty(
                        enabled=True
                    ),
                    # scram=msk.CfnCluster.ScramProperty(
                    #     enabled=False
                    # )
                ),
                # tls=msk.CfnCluster.TlsProperty(
                #     certificate_authority_arn_list=[
                #         "certificateAuthorityArnList"],
                #     enabled=False
                # ),
                unauthenticated=msk.CfnCluster.UnauthenticatedProperty(
                    enabled=False
                )
            ),
            # configuration_info=msk.CfnCluster.ConfigurationInfoProperty(
            #     arn="arn:aws:kafka:us-east-1:123456789012:configuration/my-configuration",
            #     revision=1
            # )
            # encryption_info=msk.CfnCluster.EncryptionInfoProperty(
            #     encryption_at_rest=msk.CfnCluster.EncryptionAtRestProperty(
            #         data_volume_kms_key_id="arn:aws:kms:us-east-1:123456789012:key/1234abcd-12ab-34cd-56ef-123456789012",
            #     ),
            #     encryption_in_transit=msk.CfnCluster.EncryptionInTransitProperty(
            #         client_broker="TLS",
            #     ),
            # ),
            # logging_info=msk.CfnCluster.LoggingInfoProperty(
            #     broker_logs=msk.CfnCluster.BrokerLogsProperty(
            #         cloud_watch_logs=msk.CfnCluster.CloudWatchLogsProperty(
            #             enabled=True,
            #             log_group="arn:aws:logs:us-east-1:123456789012:log-group:MyLogGroup",
            #         ),
            #     ),
            # ),
            # tags=[
            #     {"key": "Name", "value": "CdkMskCluster"},
            # ],
        )

        # example resource
        # queue = sqs.Queue(
        #     self, "CdkMskQueue",
        #     visibility_timeout=Duration.seconds(300),
        # )
