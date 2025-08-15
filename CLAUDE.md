# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This is a Nix flake-based homebase configuration. No traditional build system (Make, npm, etc.) is used.

### Basic Operations
- `nix flake check` - Validate flake syntax and check outputs
- `nix build` - Build the default package for your system
- `nix develop` - Enter development shell with dependencies
- `nix flake update` - Update flake.lock with latest input versions

### Building Packages
- `nix build .#packages.x86_64-linux.default` - Build for x86_64 Linux
- `nix build .#packages.aarch64-darwin.default` - Build for ARM64 macOS

### Development and Testing
- Check individual package builds: `nix build .#<package-name>`
- Format Nix code: `nixfmt` (custom wrapper in pkg/nixfmt)
- Test template packages locally before committing changes

## Architecture Overview

This repository implements a personal "homebase" environment using Nix flakes. The architecture follows a modular, template-based approach:

### Core Structure
- **flake.nix**: Entry point defining inputs (nixpkgs, external flakes) and supported systems
- **homebase.nix**: Main package definitions and system-specific selections
- **lib/**: Core framework code for building the homebase environment
  - **defineHomebase.nix**: Orchestrates package building across systems
  - **forSystem/**: System-specific utilities and package builders
  - **templatePackage/**: Framework for building packages from templates

### Package Organization
- **pkg/**: Custom packages and scripts organized by function
  - Each subdirectory becomes a package using the `templatePackage` system
  - Template files use `.homebase-template` extension and are processed with Jinja2
  - Dependencies declared in `homebase.nix` via the `templatePackage` function

### Template System
The repository uses a custom templating system where:
- Files ending in `.homebase-template` are processed as Jinja2 templates
- Template variables are derived from package dependencies declared in `homebase.nix`
- The `templatePackage` function builds these into final derivations
- Example: `pkg/bash-scripts/` contains many templated shell scripts

### System Support
- **x86_64-linux**: Full desktop environment with X11 tools, notifications, etc.
- **aarch64-darwin**: macOS-compatible subset with development tools

### Key Components
- **bashrc-dir**: Custom bash environment with git integration and prompt
- **xdg-config**: XDG configuration for git, helix, zellij, etc.
- **git-user-hooks**: Custom git hooks system
- **bash-scripts**: Collection of utility scripts for development workflow

The design prioritizes declarative package management, cross-system compatibility, and template-based configuration generation.