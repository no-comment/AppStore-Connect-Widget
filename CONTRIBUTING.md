# Contributing to AC Widget
[![Issues](https://img.shields.io/github/issues/no-comment/AppStore-Connect-Widget)](https://github.com/no-comment/AppStore-Connect-Widget/issues)
[![Contributors](https://img.shields.io/github/contributors/no-comment/AppStore-Connect-Widget)](https://github.com/no-comment/AppStore-Connect-Widget/graphs/contributors)

## Branch Etiquette

Please always *fork* from the `development`-branch. *Pull requests* should also be made into this branch. The `main`-branch represents the current code in live production. Any pull requests into `main` will be rejected.

### Branch Naming
To have a better overview, please name your branches according to the following scheme:

- `feature/`: This branch introduces a new feature
- `bugfix/`: This branch fixes a bug
- `localisation/<language>`: This branch adds or improves upon the localisation/language

*Example:* A branch introducing a new proceeds widget would be named `feature/proceeds-widget`.

## Pull Requests
As mentioned above: ***always target pull-requests at the `development`-branch.***

- To make it easier for us to review your pull requests, a descriptive title and description is much apreciated.
- We also encourage you to use *labels*. 
- Whenevr possible, link the pull request to the GitHub-issue it is resolving/referring to
- When you are still working on the branch, preceed the pull Request title with `[WIP]`.
- In order for the Pull Request to be merged, it must pass all swiftlint checks.