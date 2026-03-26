# Workflow Source Control and Deployment

This section explains how to use Integration Soup workflow files with source control and deployment automation.

Integration Soup treats the workflow directory as a local folder of current workflow files. Source control, CI/CD, and deployment tooling sit around that folder.

## Start here

1. Read [Workflow Directory and Source Control](workflow-directory.md) first.
2. If you use GitHub, continue to [GitHub Integration](github.md).
3. If you use another git-based platform, continue to [Generic Git Patterns](generic-git.md).
4. For Docker, multiple servers, or load-balanced deployments, read [Deployment Patterns](deployment-patterns.md).

## Decision guide

| If you need to... | Start with... |
|---|---|
| Understand how Integration Soup loads, saves, deletes, and imports workflow files | [Workflow Directory and Source Control](workflow-directory.md) |
| Use GitHub as the main repository and deployment control plane | [GitHub Integration](github.md) |
| Apply the same ideas to GitLab, Azure DevOps, Bitbucket, or self-hosted git | [Generic Git Patterns](generic-git.md) |
| Roll out the same workflow set to Docker containers or multiple hosts | [Deployment Patterns](deployment-patterns.md) |

## Product boundary

Integration Soup:

- reads and writes local workflow files
- imports workflows from the local workflow directory
- can detect newly dropped workflow files automatically or on restart

External tooling typically provides:

- run `git pull`, `git push`, or `git commit`
- choose a branch strategy for you
- deploy workflow files to remote machines
- orchestrate container rollout or load-balancer changes

Those parts are handled by external tooling such as git clients, deployment scripts, GitHub Actions, GitLab CI, Azure DevOps pipelines, container orchestration, or configuration management tools.

## Pages in this section

- [Workflow Directory and Source Control](workflow-directory.md)
- [GitHub Integration](github.md)
- [Generic Git Patterns](generic-git.md)
- [Deployment Patterns](deployment-patterns.md)
