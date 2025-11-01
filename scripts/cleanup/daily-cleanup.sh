#!/bin/zsh
# ============================================================================
# daily-cleanup.sh
# Descrição: Limpeza diária automática do macOS para liberar espaço e memória
# Autor: Gabriel Ramos
# Criado em: 2025-11-01
# Inspirado em: https://github.com/tw93/Mole.git
# ============================================================================

set -euo pipefail  # Fail fast em erros

# ============================================================================
# CONFIGURAÇÕES
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
readonly LOG_DIR="$HOME/.local/logs"
readonly LOG_FILE="$LOG_DIR/daily-cleanup.log"
readonly CONFIG_FILE="$HOME/.config/cleanup/config.sh"

# Criar diretório de logs se não existir
mkdir -p "$LOG_DIR"
mkdir -p "$HOME/.config/cleanup"

# Limites de dias para arquivos antigos
readonly DOWNLOADS_DAYS=30
readonly TRASH_DAYS=7
readonly LOGS_DAYS=14

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

# Função para obter tamanho de diretório em formato legível
get_size() {
  du -sh "$1" 2>/dev/null | awk '{print $1}' || echo "0B"
}

# Função para contar arquivos em diretório
count_files() {
  find "$1" -type f 2>/dev/null | wc -l | xargs
}

# Função para enviar notificação do macOS
notify() {
  osascript -e "display notification \"$2\" with title \"🧹 Limpeza Diária\" subtitle \"$1\""
}

# ============================================================================
# TAREFAS DE LIMPEZA
# ============================================================================

cleanup_downloads() {
  log_info "Limpando Downloads antigos (>${DOWNLOADS_DAYS} dias)..."

  local downloads_dir="$HOME/Downloads"
  local before_size=$(get_size "$downloads_dir")
  local before_count=$(count_files "$downloads_dir")

  # Remover arquivos antigos dos Downloads
  find "$downloads_dir" -type f -mtime +${DOWNLOADS_DAYS} -delete 2>/dev/null || true

  local after_size=$(get_size "$downloads_dir")
  local after_count=$(count_files "$downloads_dir")

  log_success "Downloads: $before_size → $after_size | Arquivos: $before_count → $after_count"
}

cleanup_trash() {
  log_info "Esvaziando Lixeira..."

  local trash_dir="$HOME/.Trash"
  local trash_size=$(get_size "$trash_dir")

  # Remover arquivos antigos da lixeira
  find "$trash_dir" -mtime +${TRASH_DAYS} -delete 2>/dev/null || true

  log_success "Lixeira esvaziada: $trash_size liberado"
}

cleanup_caches() {
  log_info "Limpando caches do sistema..."

  local total_freed=0

  # Cache do usuário (seletivo - não apaga tudo)
  local user_cache="$HOME/Library/Caches"

  # Limpar apenas caches conhecidos que podem ser recriados
  local cache_targets=(
    "com.apple.Safari/Webpage Previews"
    "com.google.Chrome/Default/Cache"
    "Firefox/Profiles/*/cache2"
  )

  for target in "${cache_targets[@]}"; do
    local target_path="$user_cache/$target"
    if [ -d "$target_path" ]; then
      local size=$(get_size "$target_path")
      rm -rf "$target_path" 2>/dev/null || true
      log_success "Cache removido: $target ($size)"
    fi
  done

  # Limpar cache do Homebrew
  if command -v brew >/dev/null 2>&1; then
    log_info "Limpando cache do Homebrew..."
    brew cleanup --prune=7 2>&1 | tee -a "$LOG_FILE"
  fi
}

cleanup_logs() {
  log_info "Limpando logs antigos (>${LOGS_DAYS} dias)..."

  # Limpar logs do sistema (apenas do usuário)
  local user_logs="$HOME/Library/Logs"

  find "$user_logs" -type f -name "*.log" -mtime +${LOGS_DAYS} -delete 2>/dev/null || true

  # Limpar logs próprios antigos
  find "$LOG_DIR" -type f -name "*.log" -mtime +${LOGS_DAYS} -delete 2>/dev/null || true

  log_success "Logs antigos removidos"
}

cleanup_tmp() {
  log_info "Limpando arquivos temporários..."

  # Limpar /tmp do usuário (macOS limpa automaticamente, mas forçamos)
  find "$TMPDIR" -type f -mtime +1 -delete 2>/dev/null || true

  log_success "Temporários limpos"
}

cleanup_npm_cache() {
  if command -v npm >/dev/null 2>&1; then
    log_info "Limpando cache do npm..."
    npm cache clean --force 2>&1 | tee -a "$LOG_FILE" || true
    log_success "Cache do npm limpo"
  fi
}

cleanup_docker() {
  if command -v docker >/dev/null 2>&1; then
    log_info "Limpando containers e imagens Docker não utilizados..."

    # Apenas se Docker estiver rodando
    if docker info >/dev/null 2>&1; then
      docker system prune -f 2>&1 | tee -a "$LOG_FILE" || true
      log_success "Docker limpo"
    else
      log_warning "Docker não está rodando, pulando limpeza"
    fi
  fi
}

# ============================================================================
# FUNÇÃO PRINCIPAL
# ============================================================================

main() {
  log_info "========================================"
  log_info "Iniciando limpeza diária do sistema"
  log_info "========================================"

  local start_time=$(date +%s)

  # Carregar configuração customizada se existir
  [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

  # Executar tarefas de limpeza
  cleanup_downloads
  cleanup_trash
  cleanup_caches
  cleanup_logs
  cleanup_tmp
  cleanup_npm_cache
  cleanup_docker

  # Calcular tempo de execução
  local end_time=$(date +%s)
  local elapsed=$((end_time - start_time))

  log_info "========================================"
  log_success "Limpeza concluída em ${elapsed}s"
  log_info "========================================"

  # Enviar notificação
  notify "Concluído" "Limpeza diária executada com sucesso em ${elapsed}s"

  # Mostrar espaço em disco
  log_info "Espaço em disco:"
  df -h / | tee -a "$LOG_FILE"
}

# ============================================================================
# EXECUTAR
# ============================================================================

main "$@"
