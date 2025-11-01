#!/bin/bash

# ============================================================================
# SCRIPT DE INSTALAÇÃO DE TEMAS ITERM2
# Gabriel Ramos - Brasília, DF
# Descrição: Instala temas do repositório mbadolato/iTerm2-Color-Schemes
# ============================================================================

set -e  # Sair se houver erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# FUNÇÕES AUXILIARES
# ============================================================================

print_header() {
  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}!${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

# ============================================================================
# VERIFICAÇÕES INICIAIS
# ============================================================================

check_iterm() {
  print_header "Verificando iTerm2"
  
  if [[ ! -d "/Applications/iTerm.app" ]]; then
    print_error "iTerm2 não encontrado em /Applications/iTerm.app"
    print_info "Instale o iTerm2 em: https://www.iterm2.com/"
    exit 1
  fi
  
  print_success "iTerm2 encontrado"
}

check_git() {
  print_header "Verificando Git"
  
  if ! command -v git &> /dev/null; then
    print_error "Git não está instalado"
    print_info "Instale via Homebrew: brew install git"
    exit 1
  fi
  
  print_success "Git encontrado"
}

check_dependencies() {
  check_iterm
  check_git
}

# ============================================================================
# MENU DE SELEÇÃO
# ============================================================================

show_menu() {
  print_header "Instalador de Temas iTerm2"
  
  echo "Escolha uma opção:"
  echo ""
  echo "  1) Instalar TODOS os temas (200+)"
  echo "  2) Instalar temas recomendados (10)"
  echo "  3) Instalar temas específicos (interativo)"
  echo "  4) Apenas clonar repositório (sem instalar)"
  echo "  5) Sair"
  echo ""
  read -p "Opção [1-5]: " choice
}

# ============================================================================
# CLONAGEM DO REPOSITÓRIO
# ============================================================================

clone_repo() {
  local repo_url="https://github.com/mbadolato/iTerm2-Color-Schemes.git"
  REPO_DIR="$HOME/.iterm2-themes"

  print_header "Clonando Repositório"

  if [[ -d "$REPO_DIR" ]]; then
    print_warning "Diretório $REPO_DIR já existe"
    read -p "Deseja atualizar? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
      cd "$REPO_DIR"
      git pull origin master
      print_success "Repositório atualizado"
    else
      print_success "Usando repositório existente"
    fi
  else
    print_info "Clonando mbadolato/iTerm2-Color-Schemes..."
    git clone "$repo_url" "$REPO_DIR" 2>&1 | grep -E "Cloning|done"
    print_success "Repositório clonado em: $REPO_DIR"
  fi
}

# ============================================================================
# INSTALAÇÃO DE TEMAS
# ============================================================================

install_all_themes() {
  print_header "Instalando TODOS os Temas"
  print_info "Isso pode levar alguns minutos..."

  cd "$REPO_DIR"

  # Verificar se script de import existe
  if [[ ! -f "tools/import-scheme.sh" ]]; then
    print_error "Script de importação não encontrado"
    return 1
  fi

  # Executar importação
  bash tools/import-scheme.sh schemes/* 2>&1 | tail -10

  print_success "Todos os temas instalados!"
}

install_recommended_themes() {
  print_header "Instalando Temas Recomendados"

  local themes=(
    "schemes/Dracula.itermcolors"
    "schemes/Nord.itermcolors"
    "schemes/Gruvbox Dark Hard.itermcolors"
    "schemes/Snazzy.itermcolors"
    "schemes/One Dark.itermcolors"
    "schemes/Solarized Dark.itermcolors"
    "schemes/Material Design Colors.itermcolors"
    "schemes/Molokai.itermcolors"
    "schemes/Atom One Dark.itermcolors"
    "schemes/Catppuccin Mocha.itermcolors"
  )

  cd "$REPO_DIR"

  print_info "Instalando ${#themes[@]} temas..."

  for theme in "${themes[@]}"; do
    if [[ -f "$theme" ]]; then
      theme_name=$(basename "$theme" .itermcolors)
      print_info "→ Instalando: $theme_name"
    fi
  done

  bash tools/import-scheme.sh "${themes[@]}" 2>&1 | tail -5

  print_success "Temas recomendados instalados!"
}

install_interactive_themes() {
  print_header "Seletor Interativo de Temas"

  cd "$REPO_DIR/schemes"

  print_info "Temas disponíveis em: $REPO_DIR/schemes"
  echo ""

  # Listar alguns temas populares
  echo "Temas Populares:"
  ls -1 *.itermcolors | head -20 | nl

  echo ""
  read -p "Digite os números dos temas (separados por espaço, ex: 1 3 5): " -a theme_numbers

  local selected_themes=()
  for num in "${theme_numbers[@]}"; do
    local theme=$(ls -1 *.itermcolors | sed -n "${num}p")
    if [[ -n "$theme" ]]; then
      selected_themes+=("$REPO_DIR/schemes/$theme")
    fi
  done

  if [[ ${#selected_themes[@]} -eq 0 ]]; then
    print_error "Nenhum tema selecionado"
    return 1
  fi

  print_info "Instalando ${#selected_themes[@]} tema(s)..."

  cd "$REPO_DIR"
  bash tools/import-scheme.sh "${selected_themes[@]}" 2>&1 | tail -5

  print_success "${#selected_themes[@]} tema(s) instalado(s)!"
}

# ============================================================================
# PÓS-INSTALAÇÃO
# ============================================================================

post_install() {
  print_header "Próximas Etapas"
  
  echo "Para ativar um tema instalado:"
  echo ""
  echo "  1. Abra iTerm2"
  echo "  2. Pressione ${BLUE}Cmd + i${NC} (ou vá em Preferences > Profiles > Colors)"
  echo "  3. Clique em \"Color Presets\""
  echo "  4. Selecione seu tema favorito"
  echo ""
  
  echo "Sugestões:"
  echo "  • Para Powerlevel10k: Dracula, Nord ou Gruvbox"
  echo "  • Para visão noturna: Solarized Dark ou Molokai"
  echo "  • Para design moderno: Material Design Colors ou Catppuccin"
  echo ""
  
  read -p "Deseja abrir iTerm2 agora? (s/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Ss]$ ]]; then
    open /Applications/iTerm.app
    print_success "iTerm2 aberto!"
  fi
}

# ============================================================================
# FUNÇÃO PRINCIPAL
# ============================================================================

main() {
  clear
  
  # Verificar dependências
  check_dependencies
  
  # Loop do menu
  while true; do
    show_menu

    case $choice in
      1)
        clone_repo
        install_all_themes
        post_install
        ;;
      2)
        clone_repo
        install_recommended_themes
        post_install
        ;;
      3)
        clone_repo
        install_interactive_themes
        post_install
        ;;
      4)
        clone_repo
        print_success "Repositório pronto em: $REPO_DIR"
        echo ""
        echo "Instale temas manualmente:"
        echo "  cd $REPO_DIR"
        echo "  bash tools/import-scheme.sh schemes/NomeTema.itermcolors"
        ;;
      5)
        print_info "Até logo!"
        exit 0
        ;;
      *)
        print_error "Opção inválida"
        ;;
    esac

    echo ""
    read -p "Pressione Enter para voltar ao menu..."
  done
}

# ============================================================================
# EXECUÇÃO
# ============================================================================

main
