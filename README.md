
# Automate EKS Cluster Setup on AWS

To use these TF scripts make sure TerraForm is installed on your machine
`https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli`

Clone this repo

`$ git clone https://gitlab.com/ejejosh/automate-eks-cluster-setup-on-aws.git`

For initialization

`$ terraform init`


Then validate

`$ terraform validate`

If no template errors are found you can run a plan:

`$ terraform plan`

This will show you how many resources will be created
You will need to input certain variables at each prompt (such access keys, secrets, etc)

When you are ready to deploy:

`$ terraform apply`

When you are done, please clean up:

`$ terraform plan -destroy`

This will show us which resources are going to be destroy

To apply this:
`$ terraform destroy`


# To run a pod on this new EKS cluster and also have an IAM role assigned that allows that pod to access an S3 bucket.

To demonstrate how an end-user can run a pod on a new EKS cluster and have an IAM role assigned that allows that pod to access an S3 bucket, you need to follow these steps:
1. Create an IAM Role:
Create an IAM role that grants permissions to access the desired S3 bucket. Attach a policy to this role that provides the necessary permissions.

2. Create a Kubernetes Service Account:
Create a Kubernetes service account that associates with the IAM role you created in the previous step. This service account will be used by the pod to assume the IAM role and access the S3 bucket.

3. Deploy a Pod:
Deploy a pod to the EKS cluster and configure it to use the Kubernetes service account you created. Ensure that the pod has the necessary configuration to access the S3 bucket.

Here's how you can accomplish these steps:


## Step 1: Create an IAM Role and Policy
You can create an IAM role and policy using AWS CLI or AWS Management Console. For example, you can create a policy named s3-access-policy with permissions to access the S3 bucket:
``` json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3Access",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::your-bucket-name/*"
        }
    ]
}
```

Create an IAM role eks-s3-access-role and attach the s3-access-policy to it.


## Step 2: Create a Kubernetes Service Account
Create a Kubernetes service account s3-access-sa.yaml:
``` yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-access-sa
```

## Step 3: Create a Kubernetes Role and RoleBinding
Create a Kubernetes role and role binding that allows the service account to assume the IAM role:
``` yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: s3-access-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: s3-access-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: s3-access-role
subjects:
- kind: ServiceAccount
  name: s3-access-sa
```

## Step 4: Deploy a Pod
Deploy a pod that uses the service account:
``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: s3-access-pod
spec:
  serviceAccountName: s3-access-sa
  containers:
  - name: my-container
    image: <your-image>
    command: [ "sh", "-c", "while true; do sleep 3600; done" ]  # Placeholder command
```

## Finally
Apply the YAML files to your EKS cluster:

`$ kubectl apply -f s3-access-sa.yaml`
`$ kubectl apply -f s3-access-role.yaml`
`$ kubectl apply -f s3-access-role-binding.yaml`
`$ kubectl apply -f s3-access-pod.yaml`


This setup will allow the pod to access the specified S3 bucket using the IAM role. Make sure to replace <your-bucket-name> with your actual bucket name and <your-image> with the container image you want to deploy.

