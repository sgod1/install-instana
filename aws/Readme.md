## IRSA: iam roles for service accounts
## IRSA documentation on aws:
https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html

Follow documentation link for details.<br/>

### Create oidc provider for the cluster
```
aws iam list-open-id-connect-providers
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve
```

### Create iam policy for s3 raw spans bucket.
Create iam json policy file for s3 raw spans bucket.<br/>
```
json-raw-spans-s3-bucket-policy.sh
```
Json policy file is written to `gen/raw-spans-s3-bucket-policy.json`<br/>

Create iam policy from json policy file.<br/>
```
cd gen
bin/aws iam create-policy --policy-name raw-spans-s3-bucket-policy --policy-document file://raw-spans-s3-bucket-policy.json

{
    "Policy": {
        "PolicyName": "raw-spans-s3-bucket-policy",
        "PolicyId": "xxxx",
        "Arn": "arn:aws:iam::xxxx:policy/raw-spans-s3-bucket-policy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2024-09-02T06:01:58+00:00",
        "UpdateDate": "2024-09-02T06:01:58+00:00"
    }
}
```

### Create iam role and grant it to a service account.
This command combines several steps: create service account, annotate service account, create role trust policy, and attach s3 policy to a role. You can perform each step separately with aws cli.<br/>
```
eksctl create iamserviceaccount --name my-service-account --namespace instana-core --cluster my-cluster --role-name my-role \
    --attach-policy-arn arn:aws:iam::111122223333:policy/spans-s3-iam-policy.json --approve
```

Confirm role and role trust policy.<br/>
```
aws iam get-role --role-name my-role --query Role.AssumeRolePolicyDocument
```

Confirm s3 policy attachment to a role.<br/>
```
aws iam list-attached-role-policies --role-name my-role --query AttachedPolicies[].PolicyArn --output text
```

Confirm service account annotations.<br/>
```
kubectl describe serviceaccount my-service-account -n instana-core
```

