---
description: Validar sintaxe e executar script Zsh/Bash manualmente antes de agendar
---

Vou validar e testar a execução de um script antes de agendá-lo no launchd.

Execute os seguintes passos:

1. **Identificar o script** que precisa ser testado (solicite ao usuário se não foi especificado)

2. **Validar sintaxe**:
   ```bash
   zsh -n <caminho-do-script>
   ```
   - Se for bash: `bash -n <caminho-do-script>`
   - Deve retornar sem erros

3. **Verificar permissões de execução**:
   ```bash
   ls -la <caminho-do-script>
   ```
   - Verificar se tem permissão de execução (`-rwxr-xr-x`)
   - Se não tiver: `chmod +x <caminho-do-script>`

4. **Executar o script manualmente**:
   ```bash
   <caminho-do-script>
   ```
   - Observar saída no terminal
   - Verificar se executa sem erros

5. **Verificar logs gerados**:
   ```bash
   tail -20 ~/.local/logs/<nome-do-script>.log
   ```
   - Verificar se logs foram criados corretamente
   - Verificar se não há erros nos logs

6. **Verificar logs de erro** (se existirem):
   ```bash
   tail -20 ~/.local/logs/<nome-do-script>-stderr.log
   ```

7. **Reportar resultado**:
   - ✅ Sintaxe válida
   - ✅ Permissões corretas
   - ✅ Executou com sucesso
   - ✅ Logs criados sem erros
   - ❌ Ou reportar problemas encontrados com detalhes

**Se tudo estiver OK**, informar que o script está pronto para ser agendado no launchd usando `./scripts/install-agents.sh install`.
