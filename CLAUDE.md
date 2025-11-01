# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Propósito do Repositório

Este repositório contém scripts pessoais para automação de tarefas rotineiras e repetitivas no macOS. O foco é em scripts que automatizam:

1. **Limpeza diária**: Scripts que executam 2x por dia (baseado em https://github.com/tw93/Mole.git)
2. **Atualização de dotfiles**: Manutenção automática de configurações

## Contexto do Ambiente

- **Hardware**: MacBook Air M3 com 8GB RAM (ARM64/Apple Silicon)
- **Sistema**: macOS (Darwin) com Zsh/Oh My Zsh
- **Considerações**: Scripts devem ser eficientes em memória devido à limitação de 8GB RAM

## Estrutura Esperada

O repositório está em fase inicial. Scripts futuros devem:
- Ser compatíveis com arquitetura ARM64 (Apple Silicon)
- Utilizar ferramentas disponíveis via Homebrew quando necessário
- Seguir convenções do Zsh/Oh My Zsh para integração com shell
- Incluir permissões de execução adequadas (`chmod +x`)

## Desenvolvimento

### Criando Novos Scripts
- Scripts shell devem incluir shebang apropriado (`#!/bin/zsh` ou `#!/bin/bash`)
- Adicionar comentários explicativos em português quando apropriado
- Testar compatibilidade com Apple Silicon
- Considerar uso de cron/launchd para automação de tarefas agendadas

### Ferramentas Comuns
- **Homebrew**: Gerenciador de pacotes principal
- **Zsh**: Shell padrão
- **Git**: Controle de versão (a ser inicializado)
