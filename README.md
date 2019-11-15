# Boeing3

[Work in Progress] Software for the Boeing3 project

## Change Log

See the [ChangeLog](CHANGELOG.md) for the latest developments.

## Developer Documentation

See the [docs](docs/index.md) for how-to's and other developer documentation.

## Quick guide to start up
1. Clone this repo

2. Make a copy of `.env_example` to `.env`. Modify values to suit
```
cp .env_example .env
```

3. Start up Docker Compose
```
docker-compose up -d
```

# Setting up AWS environment
Prerequisites
- S3 Bucket for hosting Athena Results
- Athena Database/S3 Data Lake
- IAM Service Account + Access Token/Secret Key with Athena Query Permissions
- Systems Manager Parameter Store

This solution uses Parameter Store to secure build variables. In the AWS Region you want to run services create the following parameters with:
```
SHINY_VERSION   (String)
ATHENA_ODBC_RPM (String)
SH_APP_ATHENA_DATABASE_ID   (String)
SH_APP_ATHENA_RESULTS_BUCKET    (String)
SH_APP_ATHENA_AWS_REGION    (String)
SH_APP_ATHENA_AWS_ACCESS_KEY_ID (String)
SH_APP_ATHENA_AWS_SECRET_ACCESS_KEY (SecureString)
SH_APP_ATHENA_ODBC_DRIVER   (String)
AUTH_USERNAME   (String)
AUTH_PASSWORD   (SecureString)
BLUE_ENDPOINT   (String)
GREEN_ENDPOINT  (String)
ACTIVE_ENDPOINT (String)
UPSTREAM_FILE   (String)
```
See .env_example for example values

IAM Service Account - Policy
To run Athena Queries the service account requires the following rights:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "glue:GetDatabase",
                "glue:GetPartition",
                "glue:GetTables",
                "s3:ListAllMyBuckets",
                "glue:GetPartitions",
                "athena:*",
                "glue:GetDatabases",
                "glue:GetTable"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucketMultipartUploads",
                "s3:AbortMultipartUpload",
                "s3:CreateBucket",
                "s3:GetObjectTagging",
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::MY-ATHENA-OUTPUT-BUCKETNAME",
                "arn:aws:s3:::MY-ATHENA-OUTPUT-BUCKETNAME/*"
            ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucketMultipartUploads",
                "s3:AbortMultipartUpload",
                "s3:CreateBucket",
                "s3:GetObjectTagging",
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:PutObjectAcl"
            ],
            "Resource": "arn:aws:s3:::aws-athena-query-results-*"
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:GetObjectTagging",
                "s3:ListBucket",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "arn:aws:s3:::MY-DATA-LAKE-BUCKETNAME/*",
                "arn:aws:s3:::MY-DATA-LAKE-BUCKETNAME"
            ]
        }
    ]
}
```
The solution is installable in any AWS account using the CloudFormation Scripts (./cf-templates) supplied.
Install them in order 1-5 either through AWS Console or aws cli. 