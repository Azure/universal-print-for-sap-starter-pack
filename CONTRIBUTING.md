
# Table of contents

- [Building "in the Open"](#building-in-the-open)
- [Coding Guidelines](#coding-guidelines)
  - [PR Basics](#pr-basics)
    - [PR guidelines](#pr-guidelines)
    - [PR reviews guidelines](#pr-reviews-guidelines)

Thanks for taking the time to contribute!
This document summarizes the deployment principles which govern our project.

## Building 'in the open'

- Our users appreciate the transparency of our project. In this context, "building in the open" means that anyone can:
    1. View the individual pull requests that comprise this solution;
    2. Understand specific changes by navigating between pull requests;
    3. Submit their own pull requests with changes, following the [Coding Guidelines](#coding-guidelines).
- Additionally, we use open-source software (OSS) tools instead of proprietary technology to build the solution.

## Coding Guidelines

This repository integrates with [GitHub Actions](https://learn.microsoft.com/en-us/azure/cloud-shell/overview), which triggers build checks on the submitted pull requests against a defined branch (e.g., main). :exclamation: All pull requests must pass the GitHub Actions test before they can be merged.

### PR Basics

This section outlines the fundamentals of how new features should be developed and fixes made to the codebase.

1. **Finalize the design before sending PRs**

- Add and describe the design by creating an issue [here](https://github.com/Azure/universal-print-for-sap-starter-pack/issues). Design discussions will take place on the issue page.

2. **Design for modularity, easy versioning, easy deployment, and rollback**

- The design should ensure it is independent and has minimal impact on other modules.
- A set of test cases should be in place to validate that the design works and will not break existing code.

### PR guidelines

1. Required information in PR ([example](https://github.com/Azure/universal-print-for-sap-starter-pack/pull/1)):
         - Always link to the issue that it is trying to resolve with the tag **Closes**.

- Describe the **Problem** that it aims to resolve.
- Provide the **Solution** that this PR offers.
- Provide **Tests** that have been conducted to ensure this PR does not break existing code (either in master or branch). If the test requires certain instructions, please include that information as well.

2. The PRs should be testable independently of other ongoing projects.

3. Submit PRs with small, descriptive commits to make it easier to rollback in case of problems.

4. While keeping the commits small, also ensure **not to stack up too many commits** (squash if needed).

### PR reviews guidelines

We aim to ensure quality along with agility. We need to agree on the base requirement and then rely on systems in place to catch and mitigate issues.

1. Focus on the [PR Basics](#pr-basics). PRs must adhere to these basics without exceptions.
2. In addition to the basics, PR reviews should focus on the quality of a PR, e.g., catching potential issues/bugs, semantic problems, nitpicks, etc.
3. Keep PRs in an open published state for at least one working day, allowing everyone in other regions to review.
4. For hotfixes, keep PRs open for at least 4 business hours.
5. The maintainer is [here](https://github.com/Azure/universal-print-for-sap-starter-pack/blob/main/CODEOWNERS).
