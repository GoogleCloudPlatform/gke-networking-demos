# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Below code creates a custom network and its subnetworks based on input values
from network*.yaml file.
Please refer to
https://github.com/GoogleCloudPlatform/deploymentmanager-samples/tree/master/examples/v2
for deployment manager samples.
"""


def GenerateConfig(context):
    """
    Generates the YAML resource configuration for a GCP network.
    The 'context' variable is to access input properties etc.
    """
    network_name = context.env['name']

    # Below input values are loaded from network*.yaml file. Change values in
    # network*.yaml file for customization.
    resources = [{
        'name': network_name,
        'type': 'compute.v1.network',
        'properties': {
            'name': network_name,
            'autoCreateSubnetworks': False,
        }
    }]

    for subnetwork in context.properties['subnetworks']:
        resources.append({
            'name':
            '%s-%s' % (subnetwork['name'], subnetwork['region']),
            'type':
            'compute.v1.subnetwork',
            'properties': {
                'name':
                '%s-%s' % (subnetwork['name'], subnetwork['region']),
                'description':
                'Subnetwork of %s in %s' % (network_name,
                                            subnetwork['region']),
                'ipCidrRange':
                subnetwork['cidr'],
                'region':
                subnetwork['region'],
                'network':
                '$(ref.%s.selfLink)' % network_name,
            },
            'metadata': {
                'dependsOn': [
                    network_name,
                ]
            }
        })

    return {'resources': resources}
