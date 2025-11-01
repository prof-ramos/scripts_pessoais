# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Propósito do Repositório

Este repositório contém scripts pessoais para automação de tarefas rotineiras e repetitivas no macOS. O foco é em scripts que automatizam:

1. **Limpeza diária**: Scripts que executam 2x por dia (inspirado em https://github.com/tw93/Mole.git)
2. **Atualização de dotfiles**: Manutenção automática de configurações do sistema

## Contexto do Ambiente

- **Hardware**: MacBook Air M3 com 8GB RAM (ARM64/Apple Silicon)
- **Sistema**: macOS (Darwin) com Zsh/Oh My Zsh
- **Shell**: Zsh como padrão
- **Gerenciador de Pacotes**: Homebrew (`/opt/homebrew` para ARM64)
- **Linguagem Preferida Python**: `uv` quando possível (conforme memória do usuário)
- **Considerações Críticas**: Scripts devem ser eficientes em memória (limitação de 8GB RAM)

## Arquitetura e Estrutura

### Estrutura de Diretórios (Planejada)

```
scripts_pessoais/
├── scripts/           # Scripts principais de automação
│   ├── cleanup/      # Scripts de limpeza diária
│   └── dotfiles/     # Scripts para atualização de dotfiles
├── launchd/          # Arquivos .plist para automação via launchd
├── config/           # Arquivos de configuração
└── docs/             # Documentação adicional
```

### Automação com launchd

Scripts de execução periódica devem usar `launchd` (não cron) no macOS:

- **Localização dos .plist**: `~/Library/LaunchAgents/` (usuário) ou `/Library/LaunchDaemons/` (sistema)
- **Comandos úteis**:
  ```bash
  # Carregar agente
  launchctl load ~/Library/LaunchAgents/com.user.script.plist

  # Descarregar agente
  launchctl unload ~/Library/LaunchAgents/com.user.script.plist

  # Listar agentes ativos
  launchctl list | grep com.user

  # Ver status
  launchctl list com.user.script
  ```

## Desenvolvimento de Scripts

### Padrões Obrigatórios

1. **Shebang**: Sempre usar `#!/bin/zsh` (shell padrão do macOS)
2. **Permissões**: Executar `chmod +x script.sh` após criar
3. **Compatibilidade**: Testar em ARM64 (Apple Silicon)
4. **Comentários**: Em português, explicando lógica complexa
5. **Nomes de variáveis**: Em inglês (padrão da indústria)

### Template de Script Base

```zsh
#!/bin/zsh
# ============================================================================
# NOME_DO_SCRIPT.sh
# Descrição: Breve descrição do que o script faz
# Autor: Gabriel Ramos
# Criado em: YYYY-MM-DD
# ============================================================================

set -euo pipefail  # Fail fast em erros

# Configurações
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="$HOME/.local/logs/script.log"

# Funções
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Script principal
main() {
  log "Iniciando script..."

  # Sua lógica aqui

  log "Script concluído com sucesso"
}

# Executar
main "$@"
```

### Checklist para Novos Scripts

- [ ] Shebang `#!/bin/zsh` incluído
- [ ] `set -euo pipefail` para fail-fast
- [ ] Logging adequado (timestamp + mensagem)
- [ ] Tratamento de erros
- [ ] Testado manualmente
- [ ] Permissões de execução (`chmod +x`)
- [ ] Documentação inline para lógica complexa
- [ ] Verificação de dependências (comandos externos)

### Considerações de Performance

Devido à limitação de 8GB de RAM:

1. **Evitar processos pesados simultâneos**
2. **Usar `pgrep` antes de iniciar serviços**
3. **Limpar variáveis grandes após uso** (`unset`)
4. **Preferir ferramentas nativas do macOS**
5. **Para Python, usar `uv` em vez de pip/venv quando possível**

### Integração com Dotfiles

Scripts que modificam dotfiles devem:

1. **Fazer backup antes de modificar**: `cp file{,.backup-$(date +%Y%m%d)}`
2. **Usar git para rastreamento**: Commit após alterações bem-sucedidas
3. **Validar sintaxe antes de aplicar**: `zsh -n ~/.zshrc` antes de substituir
4. **Principais dotfiles**: `~/.zshrc`, `~/.gitconfig`, `~/.config/`

## Ferramentas e Comandos

### Homebrew

```bash
# Instalar pacote
brew install <package>

# Atualizar tudo
brew update && brew upgrade && brew cleanup

# Verificar dependências
brew deps --tree <package>

# Homebrew em ARM64
/opt/homebrew/bin/brew
```

### Verificação de Sistema

```bash
# Arquitetura
uname -m  # arm64 para M3

# Versão do macOS
sw_vers

# Processos de desenvolvimento
checkapis  # Função customizada no ~/.zshrc (verifica APIs/processos rodando)
```

### Python com uv

Para projetos Python, SEMPRE preferir `uv`:

```bash
# Inicializar projeto
uv init

# Adicionar dependência
uv add <package>

# Executar script
uv run script.py

# Sincronizar ambiente
uv sync
```

## Referências de Inspiração

- **Mole**: https://github.com/tw93/Mole.git (limpeza automática)
  - Limpa caches, logs, downloads antigos
  - Otimização de disco
  - Execução periódica via launchd

## Notas Importantes

- **Git já está inicializado** com remoto: `https://github.com/prof-ramos/scripts_pessoais.git`
- **Branch principal**: `main`
- Scripts devem ser **idempotentes** quando possível (executar múltiplas vezes = mesmo resultado)
- Preferir **logging** em vez de output direto para scripts automatizados
- Considerar **notificações do macOS** para feedback ao usuário:
  ```bash
  osascript -e 'display notification "Mensagem" with title "Título"'
  ```
