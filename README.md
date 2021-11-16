# Action Release Support

As part of our deployments we frequently need to perform several steps

- Tagging submodules with the version used by a specific project
- Copying/tagging SAM templates in S3
- Tagging Docker images and pushing them to ECR

This composite action serves to automate these steps in a reusable action that can be used
across multiple projects.