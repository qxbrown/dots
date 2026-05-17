# ── Hyprland auto-start (must be first) ─────────────────────────────
if [[ "$(tty)" == "/dev/tty1" ]]; then
  exec Hyprland
fi

# ── PATH ─────────────────────────────────────────────────────────────
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"

# ── Environment ──────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export BROWSER="/usr/bin/brave"
export MOZ_ENABLE_WAYLAND=1
export BAT_THEME=tokyonight_night

# ── History ──────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=20000

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST

# ── Shell options ────────────────────────────────────────────────────
setopt AUTOCD
setopt PROMPT_SUBST
unsetopt BEEP

# ── Plugins ──────────────────────────────────────────────────────────
# autopair
[[ ! -d ~/.zsh-autopair ]] && git clone https://github.com/hlissner/zsh-autopair ~/.zsh-autopair
source ~/.zsh-autopair/autopair.zsh
autopair-init

# zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#555555'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# syntax highlighting
source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=white'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=green'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=green'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'

# zoxide
eval "$(zoxide init zsh)"

# ── Prompt ───────────────────────────────────────────────────────────

export PS1='%F{cyan}%n %F{magenta} %m %F{cyan}in %F{magenta}❯%f '

export RPROMPT='%F{magenta}[ %F{yellow}$(b=$(git -C . symbolic-ref --short HEAD 2>/dev/null); [[ -n $b ]] && printf "%s " $b)%F{white}%(4~|~/%2~|%~) %F{magenta}]%f'

# ── Aliases — navigation ─────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'

# ── Aliases — files ──────────────────────────────────────────────────
alias ls='exa --color=always --group-directories-first'
alias la='exa -a --color=always --group-directories-first'
alias ll='exa -l --color=always --group-directories-first'
alias cat='bat --style=plain'
alias mv='mv -i'
alias cp='cp -i'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# ── Aliases — editors ────────────────────────────────────────────────
alias v='nvim'
alias em='emacsclient -t'

# ── Aliases — packages ───────────────────────────────────────────────
alias in='paru -S'
alias un='sudo pacman -Rns'
alias up='sudo pacman -Syu'
alias prun='pacman -Qtdq | sudo pacman -Rns -'
alias pmq='pacman -Q | wofi --dmenu | wl-copy'

# ── Aliases — git ────────────────────────────────────────────────────
alias gcl='git clone'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias dotfiles='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'

# ── Aliases — tmux ───────────────────────────────────────────────────
alias t='tmux'
alias ts='tmuxsession'
alias tks='tmux kill-session'
alias fsb='~/tmux/fsb.sh'
alias fshow='~/tmux/fshow.sh'

# ── Aliases — apps ───────────────────────────────────────────────────
alias cls='clear'
alias :q='exit'
alias record='wf-recorder --file=screen.mp4'
alias dbl='bluetoothctl disconnect'
alias gh="cliphist list | wofi --dmenu | cliphist decode | wl-copy"
