# 🤖 SCRIPTS PESSOAIS

Repositório de scripts de automação para macOS que eliminam tarefas repetitivas e chatas do dia a dia.

## 📋 O que este repositório faz?

1. **🧹 Limpeza Diária Automática** - Executa 2x por dia (10h e 18h)
   - Remove arquivos antigos de Downloads
   - Esvazia a Lixeira
   - Limpa caches (navegadores, npm, Homebrew, Docker)
   - Remove logs antigos
   - Libera espaço em disco automaticamente

2. **🔄 Sincronização de Dotfiles** - Executa 1x por dia (20h)
   - Backup automático de dotfiles para `~/dotfiles`
   - Commit e push automático para Git
   - Validação de sintaxe antes de copiar
   - Rastreamento de mudanças

## 🚀 Início Rápido

### Instalação

```bash
# 1. Clonar o repositório
git clone https://github.com/prof-ramos/scripts_pessoais.git
cd scripts_pessoais

# 2. Criar diretório de logs
mkdir -p ~/.local/logs

# 3. Criar repositório de dotfiles (se não existir)
mkdir -p ~/dotfiles
cd ~/dotfiles && git init

# 4. Instalar agentes de automação
cd ~/scripts_pessoais
./scripts/install-agents.sh install
```

### Verificar Status

```bash
./scripts/install-agents.sh status
```

### Executar Manualmente

```bash
# Limpeza
./scripts/cleanup/daily-cleanup.sh

# Sync de dotfiles
./scripts/dotfiles/sync-dotfiles.sh
```

## 📂 Estrutura do Projeto

```
scripts_pessoais/
├── scripts/
│   ├── cleanup/              # Scripts de limpeza
│   │   └── daily-cleanup.sh  # Limpeza diária automática
│   ├── dotfiles/             # Scripts de dotfiles
│   │   └── sync-dotfiles.sh  # Sincronização de dotfiles
│   └── install-agents.sh     # Gerenciador de agentes launchd
├── launchd/                  # Agentes de automação
│   ├── com.gabrielramos.cleanup.plist
│   └── com.gabrielramos.dotfiles.plist
├── config/                   # Configurações
├── docs/                     # Documentação
│   └── SETUP.md             # Guia detalhado de configuração
└── CLAUDE.md                # Guia para desenvolvimento

```

## 🛠️ Comandos Úteis

```bash
# Gerenciar agentes
./scripts/install-agents.sh install    # Instalar
./scripts/install-agents.sh uninstall  # Desinstalar
./scripts/install-agents.sh status     # Ver status
./scripts/install-agents.sh reload     # Recarregar

# Ver logs
tail -f ~/.local/logs/daily-cleanup.log
tail -f ~/.local/logs/sync-dotfiles.log

# Listar agentes ativos
launchctl list | grep gabrielramos
```

## 📊 O que a Limpeza Remove?

- ✅ Arquivos em Downloads com mais de 30 dias
- ✅ Arquivos na Lixeira com mais de 7 dias
- ✅ Cache de navegadores (Safari, Chrome, Firefox)
- ✅ Cache do Homebrew (mantém últimos 7 dias)
- ✅ Cache do npm
- ✅ Containers e imagens Docker não utilizados
- ✅ Logs do sistema com mais de 14 dias
- ✅ Arquivos temporários

## 🔄 Dotfiles Sincronizados

Por padrão, os seguintes arquivos são sincronizados para `~/dotfiles`:

- `~/.zshrc`
- `~/.gitconfig`
- `~/.p10k.zsh`
- `~/.tmux.conf`
- `~/.config/nvim/init.vim`
- `~/.config/starship.toml`

> Para adicionar mais dotfiles, edite `scripts/dotfiles/sync-dotfiles.sh`

## 📅 Agendamento

| Script | Horário | Frequência |
|--------|---------|------------|
| Limpeza | 10:00 AM | Diária |
| Limpeza | 18:00 PM | Diária |
| Dotfiles | 20:00 PM | Diária |

> Para alterar horários, edite os arquivos `.plist` em `launchd/`

## 🔧 Requisitos

- macOS (testado em Apple Silicon M3)
- Zsh (shell padrão)
- Homebrew
- Git
- Repositório `~/dotfiles` criado

## 📖 Documentação

- **[SETUP.md](docs/SETUP.md)** - Guia completo de configuração e troubleshooting
- **[CLAUDE.md](CLAUDE.md)** - Guia para desenvolvimento de novos scripts

## 🎯 Próximos Passos

Após instalar, você pode:

1. **Personalizar intervalos de limpeza** - Editar constantes em `daily-cleanup.sh`
2. **Adicionar mais dotfiles** - Editar array em `sync-dotfiles.sh`
3. **Alterar horários** - Editar arquivos `.plist` e recarregar agentes
4. **Criar novos scripts** - Seguir template em `CLAUDE.md`

## 🐛 Problemas?

```bash
# Ver logs de erro
tail -f ~/.local/logs/*-stderr.log

# Recarregar agentes
./scripts/install-agents.sh reload

# Verificar permissões
ls -la scripts/cleanup/daily-cleanup.sh
```

Ver [SETUP.md](docs/SETUP.md) para troubleshooting detalhado.

## 📜 Inspiração

Inspirado em [Mole](https://github.com/tw93/Mole.git) - ferramenta de limpeza automática para macOS.

## 📝 Licença

Scripts pessoais para uso próprio. Use por sua conta e risco.

---

**Autor:** Gabriel Ramos
**Hardware:** MacBook Air M3 (8GB RAM)
**Sistema:** macOS com Zsh/Oh My Zsh
