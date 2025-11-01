#!/bin/zsh
# ============================================================================
# install-agents.sh
# Descrição: Instala ou desinstala os agentes launchd para automação
# Autor: Gabriel Ramos
# Criado em: 2025-11-01
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURAÇÕES
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly LAUNCHD_DIR="$REPO_ROOT/launchd"
readonly USER_AGENTS="$HOME/Library/LaunchAgents"

# Lista de agentes
readonly AGENTS=(
  "com.gabrielramos.cleanup"
  "com.gabrielramos.dotfiles"
)

# ============================================================================
# FUNÇÕES
# ============================================================================

print_header() {
  echo ""
  echo "╔════════════════════════════════════════════════════════╗"
  echo "║  🚀 Gerenciador de Agentes launchd                    ║"
  echo "║  Scripts Pessoais - Gabriel Ramos                     ║"
  echo "╚════════════════════════════════════════════════════════╝"
  echo ""
}

print_info() {
  echo "ℹ️  $*"
}

print_success() {
  echo "✅ $*"
}

print_error() {
  echo "❌ $*"
}

print_warning() {
  echo "⚠️  $*"
}

# Verificar se agente está carregado
is_loaded() {
  local agent="$1"
  launchctl list | grep -q "$agent"
}

# Instalar agente
install_agent() {
  local agent="$1"
  local plist_file="$LAUNCHD_DIR/${agent}.plist"
  local target_file="$USER_AGENTS/${agent}.plist"

  print_info "Instalando: $agent"

  # Verificar se arquivo existe
  if [ ! -f "$plist_file" ]; then
    print_error "Arquivo não encontrado: $plist_file"
    return 1
  fi

  # Criar diretório se não existir
  mkdir -p "$USER_AGENTS"

  # Copiar arquivo
  cp "$plist_file" "$target_file"
  print_success "Arquivo copiado para $target_file"

  # Carregar agente
  launchctl load "$target_file" 2>&1
  print_success "Agente carregado"

  # Verificar se foi carregado
  if is_loaded "$agent"; then
    print_success "$agent instalado e ativo"
  else
    print_warning "$agent copiado mas não está ativo"
  fi
}

# Desinstalar agente
uninstall_agent() {
  local agent="$1"
  local target_file="$USER_AGENTS/${agent}.plist"

  print_info "Desinstalando: $agent"

  # Descarregar agente se estiver carregado
  if is_loaded "$agent"; then
    launchctl unload "$target_file" 2>&1
    print_success "Agente descarregado"
  else
    print_info "Agente não estava carregado"
  fi

  # Remover arquivo
  if [ -f "$target_file" ]; then
    rm "$target_file"
    print_success "Arquivo removido: $target_file"
  else
    print_info "Arquivo não encontrado: $target_file"
  fi

  print_success "$agent desinstalado"
}

# Listar status dos agentes
list_agents() {
  print_info "Status dos agentes:"
  echo ""

  for agent in "${AGENTS[@]}"; do
    local plist_file="$USER_AGENTS/${agent}.plist"

    if [ -f "$plist_file" ]; then
      if is_loaded "$agent"; then
        echo "  ✅ $agent (instalado e ativo)"
      else
        echo "  ⚠️  $agent (instalado mas inativo)"
      fi
    else
      echo "  ❌ $agent (não instalado)"
    fi
  done

  echo ""
}

# Mostrar ajuda
show_help() {
  cat <<EOF
Uso: $0 [comando]

Comandos disponíveis:
  install     - Instala todos os agentes
  uninstall   - Desinstala todos os agentes
  status      - Mostra status dos agentes
  reload      - Recarrega os agentes (desinstala e instala novamente)
  help        - Mostra esta ajuda

Agentes disponíveis:
  • com.gabrielramos.cleanup   - Limpeza diária (10h e 18h)
  • com.gabrielramos.dotfiles  - Sync de dotfiles (20h)

Exemplos:
  $0 install   # Instala todos os agentes
  $0 status    # Verifica status
  $0 reload    # Recarrega configurações

Para gerenciar manualmente:
  launchctl load ~/Library/LaunchAgents/com.gabrielramos.cleanup.plist
  launchctl unload ~/Library/LaunchAgents/com.gabrielramos.cleanup.plist
  launchctl list | grep gabrielramos
EOF
}

# ============================================================================
# COMANDOS PRINCIPAIS
# ============================================================================

cmd_install() {
  print_header
  print_info "Instalando agentes..."
  echo ""

  for agent in "${AGENTS[@]}"; do
    install_agent "$agent"
    echo ""
  done

  print_success "Todos os agentes foram instalados!"
  echo ""
  list_agents
}

cmd_uninstall() {
  print_header
  print_info "Desinstalando agentes..."
  echo ""

  for agent in "${AGENTS[@]}"; do
    uninstall_agent "$agent"
    echo ""
  done

  print_success "Todos os agentes foram desinstalados!"
}

cmd_status() {
  print_header
  list_agents
}

cmd_reload() {
  print_header
  print_info "Recarregando agentes..."
  echo ""

  cmd_uninstall
  echo ""
  cmd_install
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  local command="${1:-help}"

  case "$command" in
    install)
      cmd_install
      ;;
    uninstall)
      cmd_uninstall
      ;;
    status)
      cmd_status
      ;;
    reload)
      cmd_reload
      ;;
    help|--help|-h)
      print_header
      show_help
      ;;
    *)
      print_error "Comando desconhecido: $command"
      echo ""
      show_help
      exit 1
      ;;
  esac
}

main "$@"
