# Contributing to UKHO.ADM

Firstly, thank you for taking the time for contribute! It is appreciated.

These are only guidelines for contributing to this repo, not hard rules. They may not fit all scenarios encountered, so please use your best judgment and feel free to propose a change to this document via a pull request if you think it can be improved.

## Questions

If you have any questions, please open an issue.

## Improvements

If you have any improvements (internal tweaks, optimisations, refactoring) please feel free to make changes and open a pull request detailing the changes and reasoning you have made for them. These types of changes **NEED** to be non-breaking.

## Change

If you would like to make changes (breaking changes, substantial changes, new features) the best approach is to open an issue with the details/ideas so we can discuss the changes before a pull request is made. If no issue is made before a pull request we will still consider it, however there is chance the your effort is wasted if we don't accept your pull request in :(

## Code Standards

### Functions

There should only be **one function per file**. They should follow the standard cmdlet format(see below) providing typed parameters where possible. Externally exposed cmdlets must be headed with metadata for helptext and examples.

```powershell
<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>
function Verb-Noun {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
    }
    
    process {
    }
    
    end {
    }
}
```

Any functions within the `functions` folder will be exposed in the public API. If a function is only used by internally this needs to be in the folder called `internal`.

## Versioning

You **MUST** manually change the version number before a pull request is merged.

We follow [Semantic Versioning](https://semver.org/) (SemVer) guidelines, which can be summarised as:

- MAJOR version when you make incompatible/breaking API changes.
  - **1**.0.0
- MINOR version when you add functionality in a backwards-compatible manner.
  - 1.**2**.0
  - Adding a brand new feature is a minor version change
- PATCH version when you make refactor internals or backwards-compatible bug fixes.
  - 1.2.**1**
  - The resulting change should be invisible to users if it is a refactor. Changing a behaviour can be a [breaking change](http://technosophos.com/2018/07/04/be-nice-and-write-stable-code.html).

## Build

This project will be built using Azure DevOps using a YAML build. The package will then be deployed to an external NuGet feed. Builds on any other branch than master will be marked as a "PreRelease" package.

## Owner

Luke - @elduddz
Marc - @marcdenman