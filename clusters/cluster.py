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
Create configuration to deploy GKE cluster.
Below code creates a GKE cluster based on input values from cluster*.yaml file
Please refer to
https://github.com/GoogleCloudPlatform/deploymentmanager-samples/tree/master/examples/v2
for deployment manager samples.
"""


def GenerateConfig(context):
    """
    Generates the YAML resource configuration for a GKE cluster.
    The 'context' variable is to access input properties etc.
    """
    name_prefix = context.env['deployment'] + '-' + context.env['name']
    cluster_name = name_prefix
    type_name = name_prefix + '-type'
    k8s_endpoints = {
        '': 'api/v1',
        '-v1beta1-extensions': 'apis/extensions/v1beta1'
    }

    # Below input values are loaded from network*.yaml file. Change values in
    # network*.yaml file for customization.
    resources = [{
        'name': cluster_name,
        'type': 'container.v1.cluster',
        'properties': {
            'zone': context.properties['zone'],
            'cluster': {
                'name': cluster_name,
                'network': context.properties['network'],
                'subnetwork': context.properties['subnet'],
                'initialNodeCount': context.properties['initialNodeCount'],
                'initialClusterVersion': context.properties['cluster-version'],
                'nodeConfig': {
                    'imageType':
                    context.properties['image-type'],
                    'tags': [context.properties['tags']],
                    'oauthScopes': [
                        'https://www.googleapis.com/auth/' + s for s in [
                            'compute', 'devstorage.read_only', 'logging.write',
                            'monitoring'
                        ]
                    ]
                },
                'ipAllocationPolicy': {
                    'useIpAliases': context.properties['enable-ip-alias'],
                    'clusterIpv4Cidr': context.properties['cluster-ipv4-cidr'],
                    'servicesIpv4Cidr':
                    context.properties['services-ipv4-cidr'],
                }
            }
        }
    }]
    outputs = []
    for type_suffix, endpoint in k8s_endpoints.iteritems():
        resources.append({
            'name': type_name + type_suffix,
            'type': 'deploymentmanager.v2beta.typeProvider',
            'properties': {
                'options': {
                    'validationOptions': {
                        # Kubernetes API accepts ints, in fields they annotate
                        # with string. This validation will show as warning
                        # rather than failure for Deployment Manager.
                        # https://github.com/kubernetes/kubernetes/issues/2971
                        'schemaValidation': 'IGNORE_WITH_WARNINGS'
                    },
                    # According to kubernetes spec, the path parameter 'name'
                    # should be the value inside the metadata field
                    # https://github.com/kubernetes/community/blob/master
                    # /contributors/devel/api-conventions.md
                    # This mapping specifies that
                    'inputMappings': [{
                        'fieldName':
                        'name',
                        'location':
                        'PATH',
                        'methodMatch':
                        '^(GET|DELETE|PUT)$',
                        'value':
                        '$.ifNull('
                        '$.resource.properties.metadata.name, '
                        '$.resource.name)'
                    }, {
                        'fieldName':
                        'metadata.name',
                        'location':
                        'BODY',
                        'methodMatch':
                        '^(PUT|POST)$',
                        'value':
                        '$.ifNull('
                        '$.resource.properties.metadata.name, '
                        '$.resource.name)'
                    }, {
                        'fieldName':
                        'Authorization',
                        'location':
                        'HEADER',
                        'value':
                        '$.concat("Bearer ",'
                        '$.googleOauth2AccessToken())'
                    }]
                },
                'descriptorUrl':
                ''.join([
                    'https://$(ref.', cluster_name, '.endpoint)/swaggerapi/',
                    endpoint
                ])
            }
        })
        outputs.append({
            'name': 'clusterType' + type_suffix,
            'value': type_name + type_suffix
        })

    return {'resources': resources, 'outputs': outputs}
