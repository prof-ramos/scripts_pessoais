---
description: Verificar status e saúde dos agentes launchd do projeto
---

Vou verificar o status de todos os agentes launchd configurados neste projeto.

Execute os seguintes comandos em paralelo:

1. **Status via script de instalação**:
   ```bash
   ./scripts/install-agents.sh status
   ```

2. **Listar agentes ativos no sistema**:
   ```bash
   launchctl list | grep gabrielramos
   ```

3. **Verificar logs recentes de erro**:
   ```bash
   tail -20 ~/.local/logs/cleanup-stderr.log
   tail -20 ~/.local/logs/dotfiles-stderr.log
   ```

4. **Verificar logs de saída recentes**:
   ```bash
   tail -20 ~/.local/logs/cleanup-stdout.log
   tail -20 ~/.local/logs/dotfiles-stdout.log
   ```

5. **Verificar última execução dos scripts principais**:
   ```bash
   tail -5 ~/.local/logs/daily-cleanup.log
   tail -5 ~/.local/logs/sync-dotfiles.log
   ```

6. **Verificar arquivos .plist instalados**:
   ```bash
   ls -la ~/Library/LaunchAgents/com.gabrielramos.*.plist
   ```

Após executar, analise e reporte:

### Status Esperado
- ✅ Agentes aparecem em `launchctl list` com PID ou status de última execução
- ✅ Logs de erro vazios ou sem erros críticos
- ✅ Logs de saída mostram execuções bem-sucedidas
- ✅ Arquivos .plist presentes em ~/Library/LaunchAgents

### Problemas Comuns e Soluções

**Se agente não aparecer em launchctl list:**
```bash
./scripts/install-agents.sh reload
```

**Se houver erros de permissão:**
```bash
chmod +x scripts/cleanup/daily-cleanup.sh
chmod +x scripts/dotfiles/sync-dotfiles.sh
```

**Se logs mostrarem PATH errors:**
- Verificar EnvironmentVariables nos .plist files
- PATH deve incluir: `/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin`

**Se logs não existirem:**
```bash
mkdir -p ~/.local/logs
```

Forneça um resumo claro do status de cada agente e quaisquer problemas encontrados.
