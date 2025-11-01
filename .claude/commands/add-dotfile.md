---
description: Adicionar novo dotfile ao sync automático diário
---

Vou adicionar um novo dotfile ao sistema de sincronização automática.

## Processo de Adição

1. **Solicitar informações ao usuário**:
   - Qual arquivo dotfile adicionar? (ex: `~/.vimrc`, `~/.config/nvim/init.vim`)
   - Qual nome usar no repositório? (ex: `vimrc`, `nvim/init.vim`)

2. **Validar o arquivo**:
   ```bash
   # Verificar se arquivo existe
   ls -la <caminho-do-arquivo>

   # Se for script shell, validar sintaxe
   zsh -n <arquivo>  # ou bash -n
   ```

3. **Ler o script atual**:
   ```bash
   cat scripts/dotfiles/sync-dotfiles.sh
   ```

4. **Localizar o array DOTFILES** no script (aproximadamente linhas 27-33)

5. **Adicionar nova entrada no array**:
   - Formato: `["caminho/completo/origem"]="nome-no-repo"`
   - Exemplo: `["$HOME/.vimrc"]="vimrc"`
   - Manter alfabetização se possível

6. **Validar sintaxe do script modificado**:
   ```bash
   zsh -n scripts/dotfiles/sync-dotfiles.sh
   ```

7. **Testar execução**:
   ```bash
   ./scripts/dotfiles/sync-dotfiles.sh
   ```

8. **Verificar se arquivo foi copiado**:
   ```bash
   ls -la ~/dotfiles/<nome-do-arquivo>
   ```

9. **Verificar logs**:
   ```bash
   tail -20 ~/.local/logs/sync-dotfiles.log
   ```

10. **Atualizar documentação**:
    - Adicionar arquivo na seção "Dotfiles Sincronizados" do README.md
    - Formato: `- ~/.nome-do-arquivo`

## Exemplo Completo

Se o usuário quer adicionar `~/.vimrc`:

1. Validar: `ls -la ~/.vimrc`
2. Editar `scripts/dotfiles/sync-dotfiles.sh`
3. Adicionar no array DOTFILES:
   ```zsh
   ["$HOME/.vimrc"]="vimrc"
   ```
4. Validar: `zsh -n scripts/dotfiles/sync-dotfiles.sh`
5. Testar: `./scripts/dotfiles/sync-dotfiles.sh`
6. Verificar: `ls -la ~/dotfiles/vimrc`
7. Atualizar README.md

## Notas Importantes

- **Arquivos de configuração aninhados**: Se o arquivo está em subdiretório (ex: `~/.config/nvim/init.vim`), use o mesmo caminho no nome de destino: `nvim/init.vim`
- **Criar diretórios no repo**: O script cria automaticamente diretórios necessários
- **Não adicionar arquivos sensíveis**: Nunca adicionar arquivos com tokens, senhas ou chaves de API
- **Validação automática**: O script só copia arquivos se a sintaxe for válida (para scripts shell)

Após completar todos os passos, informar:
- ✅ Arquivo adicionado ao array DOTFILES
- ✅ Sintaxe validada
- ✅ Teste executado com sucesso
- ✅ Arquivo copiado para ~/dotfiles
- ✅ Documentação atualizada
