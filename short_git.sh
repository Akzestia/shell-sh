#!/bin/bash

if [ -n "$ZSH_VERSION" ]; then
    if [ -f /usr/share/zsh/site-functions/_git ]; then
        autoload -Uz compinit
        compinit
    fi
elif [ -n "$BASH_VERSION" ]; then
    if [ -f /usr/share/bash-completion/completions/git ]; then
        source /usr/share/bash-completion/completions/git
    fi
fi

unalias ga 2>/dev/null || true
unalias gc 2>/dev/null || true
unalias gp 2>/dev/null || true
unalias gl 2>/dev/null || true
unalias gs 2>/dev/null || true
unalias gco 2>/dev/null || true
unalias gb 2>/dev/null || true
unalias gm 2>/dev/null || true
unalias gpr 2>/dev/null || true
unalias gcb 2>/dev/null || true
unalias gsl 2>/dev/null || true
unalias grh 2>/dev/null || true
unalias gclean 2>/dev/null || true

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() {
    echo -e "${RED}Error: $1${NC}" >&2
    return 1
}

success() {
    echo -e "${GREEN}$1${NC}"
}

warn() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

check_deps() {
    local missing_deps=()

    if ! command -v git >/dev/null 2>&1; then
        missing_deps+=("git")
    fi

    if ! command -v gh >/dev/null 2>&1; then
        missing_deps+=("GitHub CLI (gh)")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing required dependencies: ${missing_deps[*]}\nPlease install them and try again."
        return 1
    fi
}

usage() {
    cat << EOF
Git Shortcuts Usage Guide:
------------------------
Basic Commands:
  ga <file>              -> Stage file(s) (git add)
  gc <message>           -> Commit with message (git commit -m)
  gp                     -> Push changes (git push)
  gl                     -> Pull changes (git pull)
  gs                     -> Show status (git status)

Branch Management:
  gb                     -> List branches (git branch)
  gco <branch>          -> Checkout branch (git checkout)
  gcb <branch>          -> Create and checkout new branch
  gm <branch>           -> Merge branch (git merge)

GitHub PR Commands:
  gpr <title>           -> Create PR with title (empty body)
  gpr -b <body> <title> -> Create PR with title and body

Advanced Commands:
  grh                   -> Reset head (git reset HEAD)
  gsl                   -> Show last 5 commits (git log --oneline -5)

Use -h or --help with any command for more details.
EOF
}

ga() {
    if [ $# -eq 0 ]; then
        error "No files specified for git add"
        return 1
    fi
    git add "$@" || error "Failed to add files"
    success "Added files: $*"
}

gc() {
    if [ $# -eq 0 ]; then
        error "Commit message required"
        return 1
    fi
    git commit -m "$*" || error "Failed to commit"
    success "Changes committed with message: $*"
}

gp() {
    local remote="${1:-origin}"
    local branch
    branch=$(git symbolic-ref --short HEAD)

    git push "$remote" "$branch" || error "Failed to push to $remote/$branch"
    success "Pushed to $remote/$branch"
}

gl() {
    local remote="${1:-origin}"
    local branch
    branch=$(git symbolic-ref --short HEAD)

    git pull "$remote" "$branch" || error "Failed to pull from $remote/$branch"
    success "Pulled from $remote/$branch"
}

gs() {
    if [ "$1" = "-s" ]; then
        git status -s
    else
        git status
    fi
}

gco() {
    if [ $# -eq 0 ]; then
        error "Branch name required"
        return 1
    fi
    git checkout "$1" || error "Failed to checkout $1"
    success "Switched to branch: $1"
}

gcb() {
    if [ $# -eq 0 ]; then
        error "Branch name required"
        return 1
    fi
    git checkout -b "$1" || error "Failed to create branch $1"
    success "Created and switched to new branch: $1"
}

gb() {
    if [ "$1" = "-a" ]; then
        git branch -a
    else
        git branch
    fi
}

gm() {
    if [ $# -eq 0 ]; then
        error "Branch name required"
        return 1
    fi

    local current_branch
    current_branch=$(git symbolic-ref --short HEAD)

    if [ "$1" = "$current_branch" ]; then
        error "Cannot merge branch into itself"
        return 1
    fi

    if ! git diff-index --quiet HEAD --; then
        warn "You have uncommitted changes. Commit or stash them first."
        return 1
    fi

    git merge "$1" || error "Failed to merge $1"
    success "Merged $1 into $current_branch"
}

gpr() {
    if [ $# -eq 0 ]; then
        error "PR title required"
        return 1
    fi

    if [ "$1" = "-b" ]; then
        if [ $# -lt 3 ]; then
            error "Both body and title required for -b option"
            echo "Usage: gpr -b <body> <title>"
            return 1
        fi
        gh pr create --title "$3" --body "$2" || error "Failed to create PR"
        success "Created PR: $3"
    else
        gh pr create --title "$1" --body "" || error "Failed to create PR"
        success "Created PR: $1"
    fi
}

gsl() {
    local num="${1:-5}"
    git log --oneline -n "$num"
}

grh() {
    git reset HEAD "$@"
    success "Reset HEAD successfully"
}

check_deps || return 1

success "Git shortcuts loaded. Run 'usage' for details."
