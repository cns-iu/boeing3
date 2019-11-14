# Changelog

Changelog for the Boeing3 project.

## 0.0.2 - 2019-11-14

### Project Modifications for AWS ECS/Fargate Deployment

- Restructured code for CI/CD deployment to AWS ECS and Fargate
- Removed volume mounts in docker for COPY cmds (as not supported in Fargate)
- All cloud build variables controlled by AWS Systems Manager Parameter Store for AWS deployed ECS
- All local build variables controlled by .env for docker ARGS (copy .env_example to .env and modify values) using docker-compose.yml
- Runs as dual container using nginx 'meappy/nginx-blue-green' to simplify proxy ARG settings - this still builds nginx:latest
- All AWS Services controlled by CloudFormation scripts (/cf-templates) - to be installed in number order 1-5.
- Removed old .Renviron and .htpasswd config files (files now built dynamically during build)
- Altered Shiny R Dashboard - Removed Session Token, recommend use a IAM service account for Athena accesss
- Altered Shiny R Dashboard - Changed 'futures' library to plan("sequential") from plan("multiprocess") as causing issues in AWS Fargate 

## 0.0.1 - 2019-10-21

### Added in 0.0.1

- First WIP release of the project following Sprint 1!
- Created a Shiny/R dashboard that connects to the data stored in Amazon Athena
- Created a Docker container and initial Amazon Elastic Beanstalk configuration for hosting a password-protected version of the dashboard
- Initial developer-level documentation
- Initial queries and visualizations for the Shiny/R dashboard
- *Coming Soon* a full continuous deployment workflow going from code committed to dashboard updated and running on the Amazon cloud
- *Coming Soon* Shiny/R dashboard hosted on the Amazon cloud
