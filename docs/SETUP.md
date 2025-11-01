# 📚 Guia de Configuração - Scripts Pessoais

## 🎯 Visão Geral

Este repositório contém scripts de automação para macOS, focados em:
- **Limpeza diária automática** (2x por dia)
- **Sincronização de dotfiles** (1x por dia)

## 📋 Pré-requisitos

- macOS (testado em macOS com Apple Silicon M3)
- Zsh (shell padrão do macOS)
- Homebrew instalado
- Git configurado
- Repositório `~/dotfiles` criado (para sync de dotfiles)

## 🚀 Instalação Rápida

### 1. Clonar o Repositório

```bash
cd ~
git clone https://github.com/prof-ramos/scripts_pessoais.git
cd scripts_pessoais
```

### 2. Criar Diretório de Logs

```bash
mkdir -p ~/.local/logs
```

### 3. Configurar Repositório de Dotfiles

```bash
# Criar repositório de dotfiles (se ainda não existir)
mkdir -p ~/dotfiles
cd ~/dotfiles
git init
git remote add origin <seu-repo-dotfiles>
```

### 4. Instalar Agentes launchd

```bash
./scripts/install-agents.sh install
```

### 5. Verificar Instalação

```bash
./scripts/install-agents.sh status
```

## 📝 Scripts Disponíveis

### 1. Limpeza Diária (`daily-cleanup.sh`)

**Localização:** `scripts/cleanup/daily-cleanup.sh`

**O que faz:**
- Remove arquivos antigos da pasta Downloads (>30 dias)
- Esvazia a Lixeira (arquivos >7 dias)
- Limpa caches de navegadores
- Limpa cache do Homebrew
- Remove logs antigos (>14 dias)
- Limpa arquivos temporários
- Limpa cache do npm
- Limpa containers Docker não utilizados

**Execução manual:**
```bash
./scripts/cleanup/daily-cleanup.sh
```

**Execução automática:**
- 10:00 AM
- 6:00 PM

**Logs:**
- Arquivo: `~/.local/logs/daily-cleanup.log`
- Stdout: `~/.local/logs/cleanup-stdout.log`
- Stderr: `~/.local/logs/cleanup-stderr.log`

### 2. Sync de Dotfiles (`sync-dotfiles.sh`)

**Localização:** `scripts/dotfiles/sync-dotfiles.sh`

**O que faz:**
- Sincroniza dotfiles do sistema para `~/dotfiles`
- Valida sintaxe antes de copiar
- Cria backups automáticos
- Faz commit e push automático das mudanças

**Dotfiles sincronizados:**
- `~/.zshrc`
- `~/.gitconfig`
- `~/.p10k.zsh`
- `~/.tmux.conf`
- `~/.config/nvim/init.vim`
- `~/.config/starship.toml`

**Execução manual:**
```bash
./scripts/dotfiles/sync-dotfiles.sh
```

**Execução automática:**
- 8:00 PM diariamente

**Logs:**
- Arquivo: `~/.local/logs/sync-dotfiles.log`

### 3. Gerenciador de Agentes (`install-agents.sh`)

**Localização:** `scripts/install-agents.sh`

**Comandos:**

```bash
# Instalar todos os agentes
./scripts/install-agents.sh install

# Desinstalar todos os agentes
./scripts/install-agents.sh uninstall

# Ver status dos agentes
./scripts/install-agents.sh status

# Recarregar agentes (útil após editar .plist)
./scripts/install-agents.sh reload

# Ajuda
./scripts/install-agents.sh help
```

## 🔧 Configuração Avançada

### Customizar Intervalos de Limpeza

Edite o script `scripts/cleanup/daily-cleanup.sh` e altere:

```bash
readonly DOWNLOADS_DAYS=30  # Dias para manter arquivos em Downloads
readonly TRASH_DAYS=7       # Dias para manter na Lixeira
readonly LOGS_DAYS=14       # Dias para manter logs
```

### Customizar Dotfiles Sincronizados

Edite o script `scripts/dotfiles/sync-dotfiles.sh` e altere o array `DOTFILES`:

```bash
declare -A DOTFILES=(
  ["$HOME/.zshrc"]="zshrc"
  ["$HOME/.gitconfig"]="gitconfig"
  # Adicione seus dotfiles aqui
)
```

### Alterar Horários de Execução

Edite os arquivos `.plist` em `launchd/`:

```xml
<!-- Para cleanup - alterar horários -->
<key>StartCalendarInterval</key>
<array>
    <dict>
        <key>Hour</key>
        <integer>10</integer>  <!-- Altere aqui -->
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</array>
```

Depois, recarregue os agentes:
```bash
./scripts/install-agents.sh reload
```

## 🐛 Resolução de Problemas

### Agente não está executando

1. Verificar status:
```bash
launchctl list | grep gabrielramos
```

2. Ver logs de erro:
```bash
tail -f ~/.local/logs/cleanup-stderr.log
tail -f ~/.local/logs/dotfiles-stderr.log
```

3. Recarregar agente:
```bash
./scripts/install-agents.sh reload
```

### Script falha ao executar

1. Verificar permissões:
```bash
ls -la scripts/cleanup/daily-cleanup.sh
# Deve mostrar: -rwxr-xr-x
```

2. Adicionar permissão se necessário:
```bash
chmod +x scripts/cleanup/daily-cleanup.sh
chmod +x scripts/dotfiles/sync-dotfiles.sh
```

3. Testar manualmente:
```bash
./scripts/cleanup/daily-cleanup.sh
```

### Dotfiles não sincronizam

1. Verificar se repositório existe:
```bash
ls -la ~/dotfiles/.git
```

2. Verificar se há remote configurado:
```bash
cd ~/dotfiles
git remote -v
```

3. Configurar remote se necessário:
```bash
cd ~/dotfiles
git remote add origin <url-do-seu-repo>
```

## 📊 Monitoramento

### Ver logs em tempo real

```bash
# Cleanup
tail -f ~/.local/logs/daily-cleanup.log

# Dotfiles
tail -f ~/.local/logs/sync-dotfiles.log

# Ambos
tail -f ~/.local/logs/*.log
```

### Ver últimas execuções

```bash
# Últimas 20 linhas do cleanup
tail -20 ~/.local/logs/daily-cleanup.log

# Últimas 20 linhas do dotfiles
tail -20 ~/.local/logs/sync-dotfiles.log
```

### Listar agentes ativos

```bash
launchctl list | grep gabrielramos
```

## 🔒 Segurança

- Scripts validam sintaxe antes de aplicar mudanças
- Backups automáticos são criados antes de sobrescrever arquivos
- Logs são mantidos para auditoria
- Nice level baixo para não impactar performance do sistema

## 📞 Notificações

Scripts enviam notificações do macOS ao concluir:
- ✅ Sucesso: Mostra resumo da execução
- ❌ Erro: Indica que algo falhou

Para desabilitar notificações, comente a linha `notify` no final de cada script.

## 🚫 Desinstalação

```bash
# Desinstalar agentes
./scripts/install-agents.sh uninstall

# Remover logs (opcional)
rm -rf ~/.local/logs/daily-cleanup.log
rm -rf ~/.local/logs/sync-dotfiles.log
rm -rf ~/.local/logs/cleanup-*.log
rm -rf ~/.local/logs/dotfiles-*.log
```

## 📖 Mais Informações

- Ver `CLAUDE.md` para guia de desenvolvimento
- Ver `README.md` para visão geral do projeto
