# Devbox Setup

This document covers setting up devbox for Clojure projects to manage development tools like Clojure CLI and Babashka.

## Overview

[Devbox](https://www.jetify.com/devbox) provides isolated, reproducible development environments using Nix packages. Using devbox ensures all developers have the same tool versions without polluting the global system.

## Initial Setup

### Step 1: Initialize Devbox

Run in the project root:

```bash
devbox init
```

This creates a `devbox.json` file.

### Step 2: Add Clojure Tools

Add the required packages:

```bash
devbox add clojure babashka
```

For PWA projects that use Squint, also add nodejs:

```bash
devbox add clojure babashka nodejs
```

This updates `devbox.json` with the packages.

### Step 3: Set Up Direnv Integration

Generate direnv configuration for automatic shell activation:

```bash
devbox generate direnv
```

This creates `.envrc` which automatically activates the devbox environment when you enter the directory.

### Step 4: Allow Direnv

Allow direnv to load the configuration:

```bash
direnv allow
```

## devbox.json

After setup, your `devbox.json` should look like:

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/main/.schema/devbox.schema.json",
  "packages": [
    "clojure",
    "babashka"
  ],
  "shell": {
    "init_hook": [],
    "scripts": {}
  }
}
```

## Files Created

- `devbox.json` - Devbox configuration with package list
- `devbox.lock` - Lock file for reproducible builds (commit this)
- `.envrc` - Direnv configuration for auto-activation

## .gitignore Additions

Add to `.gitignore`:

```
# Devbox
.devbox/
```

Note: Do NOT ignore `devbox.json`, `devbox.lock`, or `.envrc` - these should be committed.

## Usage

### Manual Activation

If not using direnv, manually enter the devbox shell:

```bash
devbox shell
```

### Running Commands

With direnv, commands use devbox tools automatically:

```bash
clojure -M:dev
bb test
```

Without direnv, prefix with `devbox run`:

```bash
devbox run clojure -M:dev
devbox run bb test
```

## Prerequisites

Ensure these are installed on your system:

- [Devbox](https://www.jetify.com/devbox/docs/installing_devbox/)
- [Direnv](https://direnv.net/docs/installation.html) (recommended)

## Checklist

When setting up devbox for a Clojure project:

- [ ] Run `devbox init`
- [ ] Run `devbox add clojure babashka`
- [ ] Run `devbox generate direnv`
- [ ] Run `direnv allow`
- [ ] Add `.devbox/` to `.gitignore`
- [ ] Commit `devbox.json`, `devbox.lock`, and `.envrc`
