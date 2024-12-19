import aws_cdk as core
import aws_cdk.assertions as assertions

from cdk_msk.msk_stack import MskStack

# example tests. To run these tests, uncomment this file along with the example
# resource in cdk_msk/cdk_msk_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = MskStack(app, "cdk-msk")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
