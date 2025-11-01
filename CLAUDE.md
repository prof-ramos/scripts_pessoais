# CLAUDE.md - Scripts Pessoais de Automação macOS

Este arquivo fornece orientações para o Claude Code ao trabalhar neste repositório de scripts de automação para macOS.

## Contexto do Projeto

Este é um repositório de **scripts pessoais de automação** para macOS que elimina tarefas repetitivas do dia a dia usando:

- **Linguagens**: Zsh (scripts principais), Bash (iTerm2 themes)
- **Agendamento**: launchd (agentes macOS nativos)
- **Hardware**: MacBook Air M3 (8GB RAM, ARM64)
- **Sistema**: macOS com Zsh/Oh My Zsh
- **Ferramentas**: Homebrew, Git, npm, Docker

### Funcionalidades Principais

1. **Limpeza Diária Automática** (2x/dia: 10h e 18h)
   - Remove arquivos antigos de Downloads (>30 dias)
   - Esvazia Lixeira (>7 dias)
   - Limpa caches (navegadores, npm, Homebrew, Docker)
   - Remove logs antigos (>14 dias)

2. **Sincronização de Dotfiles** (1x/dia: 20h)
   - Backup automático para ~/dotfiles
   - Validação de sintaxe antes de copiar
   - Commit e push automático para Git

3. **Gerenciamento de Agentes launchd**
   - Instalação/desinstalação de agentes
   - Monitoramento de status
   - Reload de configurações

## Estrutura do Projeto

```
scripts_pessoais/
├── scripts/
│   ├── cleanup/
│   │   └── daily-cleanup.sh       # Limpeza automática de sistema
│   ├── dotfiles/
│   │   └── sync-dotfiles.sh       # Sincronização de dotfiles
│   └── install-agents.sh          # Gerenciador de agentes launchd
├── launchd/                       # Arquivos .plist para agendamento
│   ├── com.gabrielramos.cleanup.plist
│   └── com.gabrielramos.dotfiles.plist
├── install-iterm-themes.sh        # Instalador de temas iTerm2
├── config/                        # Configurações
├── docs/                          # Documentação
│   └── SETUP.md                   # Guia de configuração
└── .claude/                       # Configurações Claude Code
    ├── settings.json              # Configurações base
    ├── settings.local.json        # Permissões locais
    └── commands/                  # Slash commands customizados
```

## Convenções de Desenvolvimento

### Scripts Zsh

#### Estrutura Padrão
```zsh
#!/bin/zsh
# ============================================================================
# nome-do-script.sh
# Descrição: [Descrição breve e clara]
# Autor: Gabriel Ramos
# Criado em: YYYY-MM-DD
# ============================================================================

set -euo pipefail  # Fail fast: -e (exit on error), -u (undefined vars), -o pipefail

# CONFIGURAÇÕES
readonly SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
readonly LOG_DIR="$HOME/.local/logs"
readonly LOG_FILE="$LOG_DIR/nome-do-script.log"

# Criar diretório de logs
mkdir -p "$LOG_DIR"

# FUNÇÕES
log() {
  local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

# MAIN
main() {
  log "Iniciando script..."
  # Implementação aqui
  log "Script finalizado com sucesso"
}

main "$@"
```

#### Boas Práticas
- Use `set -euo pipefail` no início de todos os scripts
- Declare constantes com `readonly`
- Use `local` para variáveis de função
- Adicione logs estruturados com timestamp
- Valide pré-requisitos no início
- Use nomes descritivos para variáveis e funções
- Adicione comentários para lógica complexa

### Agentes launchd

#### Estrutura de Arquivos .plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.gabrielramos.nome-do-agente</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>/caminho/completo/para/script.sh</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>10</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>

    <key>WorkingDirectory</key>
    <string>/Users/gabrielramos/scripts_pessoais</string>

    <key>StandardOutPath</key>
    <string>/Users/gabrielramos/.local/logs/nome-stdout.log</string>

    <key>StandardErrorPath</key>
    <string>/Users/gabrielramos/.local/logs/nome-stderr.log</string>

    <key>Nice</key>
    <integer>10</integer>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
```

#### Convenções launchd
- **Naming**: `com.gabrielramos.<nome-do-agente>.plist`
- **Localização**: `launchd/` no repositório → `~/Library/LaunchAgents` quando instalado
- **Logs separados**: stdout e stderr em arquivos diferentes
- **Nice level**: 10 (baixa prioridade para não interferir no sistema)
- **PATH**: Incluir Homebrew paths (`/opt/homebrew/bin` para Apple Silicon)

### Logs e Monitoramento

#### Diretório de Logs
- **Localização**: `~/.local/logs/`
- **Formato**: `<nome-do-script>.log` (stdout), `<nome-do-script>-stderr.log` (erros)

#### Ver Logs
```bash
# Logs em tempo real
tail -f ~/.local/logs/daily-cleanup.log
tail -f ~/.local/logs/sync-dotfiles.log

# Ver erros
tail -f ~/.local/logs/cleanup-stderr.log
tail -f ~/.local/logs/dotfiles-stderr.log

# Últimas 50 linhas
tail -50 ~/.local/logs/daily-cleanup.log
```

## Testes e Validação

### Antes de Agendar Scripts

1. **Validar Sintaxe**
   ```bash
   zsh -n scripts/cleanup/daily-cleanup.sh
   ```

2. **Executar Manualmente**
   ```bash
   ./scripts/cleanup/daily-cleanup.sh
   ```

3. **Verificar Logs**
   ```bash
   tail -20 ~/.local/logs/daily-cleanup.log
   ```

4. **Testar Agentes launchd**
   ```bash
   # Instalar
   ./scripts/install-agents.sh install

   # Verificar status
   ./scripts/install-agents.sh status
   launchctl list | grep gabrielramos

   # Ver logs recentes
   tail ~/.local/logs/*-stderr.log
   ```

### Checklist de Validação

Antes de fazer commit de novos scripts:
- [ ] Sintaxe validada com `zsh -n`
- [ ] Script executado manualmente com sucesso
- [ ] Logs verificados (sem erros)
- [ ] Permissões de execução configuradas (`chmod +x`)
- [ ] Documentação atualizada no README.md
- [ ] Arquivo .plist criado (se aplicável)
- [ ] Agente testado com launchctl (se aplicável)

## Considerações de Performance

### Hardware Limitado (8GB RAM)
- Evitar executar múltiplos processos pesados simultaneamente
- Scripts devem ser leves e rápidos
- Usar `nice` level adequado em agentes (10 = baixa prioridade)
- Monitorar uso de memória em operações grandes

### Otimizações Específicas
```bash
# Limitar memória do Node.js se necessário
export NODE_OPTIONS="--max-old-space-size=2048"

# Usar comandos nativos quando possível
rm -rf dir/  # Mais rápido que find + rm

# Evitar múltiplos pipes desnecessários
awk '{ print $1 }' file.txt  # Melhor que cat file.txt | awk ...
```

## Gerenciamento de Configuração

### Arquivos de Ambiente
- **Não commitar**: Chaves de API, senhas, tokens
- **Usar**: Variáveis de ambiente ou arquivos `.env` no `.gitignore`
- **Documentar**: Criar `.env.example` com variáveis necessárias

### Configurações do Usuário
```bash
# Criar diretórios de configuração
mkdir -p ~/.config/cleanup
mkdir -p ~/.config/dotfiles

# Usar arquivos de configuração locais
CONFIG_FILE="$HOME/.config/cleanup/config.sh"
```

## Comandos Úteis

### Gerenciamento de Agentes
```bash
# Instalar todos os agentes
./scripts/install-agents.sh install

# Verificar status
./scripts/install-agents.sh status

# Recarregar configurações
./scripts/install-agents.sh reload

# Desinstalar
./scripts/install-agents.sh uninstall

# Listar agentes ativos
launchctl list | grep gabrielramos
```

### Diagnóstico e Troubleshooting
```bash
# Espaço em disco
df -h

# Processos em execução
ps aux | grep daily-cleanup

# Verificar permissões
ls -la scripts/cleanup/daily-cleanup.sh

# Testar PATH do launchd
launchctl getenv PATH

# Ver logs de erro do sistema
tail /var/log/system.log
```

### Limpeza Manual
```bash
# Executar limpeza agora
./scripts/cleanup/daily-cleanup.sh

# Executar sync de dotfiles agora
./scripts/dotfiles/sync-dotfiles.sh

# Limpar Docker manualmente
docker system prune -af --volumes
```

## Git Workflow

### Commits
Este é um repositório pessoal, então:
- Commits podem ser diretos na branch `main`
- Use mensagens descritivas em português
- Formato sugerido: `tipo: descrição`
  - `feat:` nova funcionalidade
  - `fix:` correção de bug
  - `docs:` mudanças na documentação
  - `refactor:` refatoração de código
  - `chore:` tarefas de manutenção

### Exemplo
```bash
git add scripts/cleanup/daily-cleanup.sh
git commit -m "feat: adiciona limpeza de cache do npm"
git push origin main
```

## Segurança

### Informações Sensíveis
- Nunca commitar tokens ou credenciais
- Revisar scripts antes de compartilhar publicamente
- Usar `~/.gitignore` para excluir logs e caches

### Permissões de Arquivos
```bash
# Scripts executáveis
chmod +x scripts/**/*.sh

# Arquivos de configuração (somente leitura)
chmod 644 launchd/*.plist
chmod 644 config/*
```

### Validação de Input
- Sempre validar paths antes de executar `rm -rf`
- Verificar se diretórios existem antes de operar
- Usar aspas em variáveis para evitar word splitting

## Referências Rápidas

### Slash Commands Disponíveis
- `/test-script` - Validar e executar scripts manualmente
- `/check-agents` - Verificar status dos agentes launchd
- `/add-dotfile` - Adicionar novo arquivo ao sync de dotfiles

### Documentação Adicional
- **[README.md](README.md)** - Visão geral e início rápido
- **[docs/SETUP.md](docs/SETUP.md)** - Guia detalhado de configuração
- **[Mole](https://github.com/tw93/Mole.git)** - Inspiração original

### Recursos Externos
- [launchd.info](https://www.launchd.info/) - Guia de launchd
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/) - Manual Zsh
- [Homebrew Docs](https://docs.brew.sh/) - Documentação Homebrew

---

**Última atualização:** 2025-11-01
**Autor:** Gabriel Ramos
**Hardware:** MacBook Air M3 (8GB RAM)
**Sistema:** macOS com Zsh/Oh My Zsh
