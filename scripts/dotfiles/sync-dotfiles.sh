#!/bin/zsh
# ============================================================================
# sync-dotfiles.sh
# Descrição: Sincroniza dotfiles entre o sistema e o repositório ~/dotfiles
# Autor: Gabriel Ramos
# Criado em: 2025-11-01
# ============================================================================

set -euo pipefail  # Fail fast em erros

# ============================================================================
# CONFIGURAÇÕES
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
readonly LOG_DIR="$HOME/.local/logs"
readonly LOG_FILE="$LOG_DIR/sync-dotfiles.log"

# Diretório do repositório de dotfiles
readonly DOTFILES_REPO="$HOME/dotfiles"

# Criar diretório de logs se não existir
mkdir -p "$LOG_DIR"

# Lista de dotfiles para sincronizar (arquivo_origem → arquivo_destino_no_repo)
declare -A DOTFILES=(
  ["$HOME/.zshrc"]="zshrc"
  ["$HOME/.gitconfig"]="gitconfig"
  ["$HOME/.p10k.zsh"]="p10k.zsh"
  ["$HOME/.tmux.conf"]="tmux.conf"
  ["$HOME/.config/nvim/init.vim"]="config/nvim/init.vim"
  ["$HOME/.config/starship.toml"]="config/starship.toml"
)

# ============================================================================
# FUNÇÕES
# ============================================================================

log() {
  local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

log_info() {
  log "ℹ️  INFO: $*"
}

log_success() {
  log "✅ SUCCESS: $*"
}

log_error() {
  log "❌ ERROR: $*"
}

log_warning() {
  log "⚠️  WARNING: $*"
}

notify() {
  osascript -e "display notification \"$2\" with title \"🔄 Sync Dotfiles\" subtitle \"$1\""
}

# Verificar se arquivo mudou comparado ao repo
has_changed() {
  local source_file="$1"
  local repo_file="$2"

  # Se arquivo não existe no repo, considerar como mudado
  [ ! -f "$repo_file" ] && return 0

  # Comparar arquivos
  ! cmp -s "$source_file" "$repo_file"
}

# Criar backup de arquivo
backup_file() {
  local file="$1"
  local backup_name="${file}.backup-$(date +%Y%m%d-%H%M%S)"

  if [ -f "$file" ]; then
    cp "$file" "$backup_name"
    log_info "Backup criado: $backup_name"
  fi
}

# Validar sintaxe de arquivo de configuração
validate_file() {
  local file="$1"

  case "$file" in
    *.zsh|*zshrc)
      zsh -n "$file" 2>/dev/null && return 0 || return 1
      ;;
    *.sh)
      bash -n "$file" 2>/dev/null && return 0 || return 1
      ;;
    *)
      return 0  # Sem validação específica
      ;;
  esac
}

# Sincronizar arquivo individual
sync_file() {
  local source="$1"
  local dest_name="$2"
  local dest="$DOTFILES_REPO/$dest_name"

  # Verificar se arquivo fonte existe
  if [ ! -f "$source" ]; then
    log_warning "Arquivo não encontrado: $source (pulando)"
    return 0
  fi

  # Validar sintaxe antes de copiar
  if ! validate_file "$source"; then
    log_error "Validação falhou para: $source (pulando)"
    return 1
  fi

  # Verificar se mudou
  if ! has_changed "$source" "$dest"; then
    log_info "Sem mudanças: $(basename $source)"
    return 0
  fi

  # Criar diretório destino se necessário
  mkdir -p "$(dirname "$dest")"

  # Fazer backup do arquivo no repo (se existir)
  [ -f "$dest" ] && backup_file "$dest"

  # Copiar arquivo
  cp "$source" "$dest"
  log_success "Sincronizado: $(basename $source) → $dest_name"

  return 0
}

# Commitar mudanças no repositório de dotfiles
commit_changes() {
  local changed_files=$1

  if [ "$changed_files" -eq 0 ]; then
    log_info "Nenhuma mudança para commitar"
    return 0
  fi

  cd "$DOTFILES_REPO"

  # Verificar se é um repositório git
  if [ ! -d ".git" ]; then
    log_warning "Diretório $DOTFILES_REPO não é um repositório Git"
    log_info "Execute: cd $DOTFILES_REPO && git init"
    return 1
  fi

  # Adicionar arquivos modificados
  git add -A

  # Criar commit
  local commit_msg="Atualização automática de dotfiles - $(date +'%Y-%m-%d %H:%M:%S')"
  git commit -m "$commit_msg" || {
    log_warning "Nenhuma mudança para commitar no Git"
    return 0
  }

  log_success "Commit criado: $commit_msg"

  # Push (se houver remote configurado)
  if git remote | grep -q origin; then
    log_info "Fazendo push para remote..."
    git push origin main 2>&1 | tee -a "$LOG_FILE" || {
      log_warning "Push falhou - verifique conectividade"
      return 1
    }
    log_success "Push concluído"
  else
    log_info "Nenhum remote configurado - pulando push"
  fi

  cd - >/dev/null
}

# ============================================================================
# FUNÇÃO PRINCIPAL
# ============================================================================

main() {
  log_info "========================================"
  log_info "Iniciando sincronização de dotfiles"
  log_info "========================================"

  # Verificar se diretório de dotfiles existe
  if [ ! -d "$DOTFILES_REPO" ]; then
    log_error "Diretório $DOTFILES_REPO não existe!"
    log_info "Crie o diretório e inicialize um repositório Git:"
    log_info "  mkdir -p $DOTFILES_REPO"
    log_info "  cd $DOTFILES_REPO"
    log_info "  git init"
    notify "Erro" "Diretório de dotfiles não existe"
    exit 1
  fi

  local changed_count=0
  local error_count=0

  # Sincronizar cada dotfile
  for source in "${(@k)DOTFILES}"; do
    dest_name="${DOTFILES[$source]}"

    if sync_file "$source" "$dest_name"; then
      if has_changed "$source" "$DOTFILES_REPO/$dest_name"; then
        ((changed_count++)) || true
      fi
    else
      ((error_count++)) || true
    fi
  done

  log_info "========================================"
  log_info "Arquivos modificados: $changed_count"
  log_info "Erros: $error_count"
  log_info "========================================"

  # Commitar mudanças se houver
  if [ "$changed_count" -gt 0 ]; then
    commit_changes "$changed_count"
  fi

  log_success "Sincronização concluída"
  notify "Concluído" "$changed_count arquivo(s) sincronizado(s)"
}

# ============================================================================
# EXECUTAR
# ============================================================================

main "$@"
