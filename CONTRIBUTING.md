# Guia de Contribuição - Game.Servers

Obrigado por considerar contribuir com o Game.Servers! Este documento fornece diretrizes para contribuições.

## 📋 Índice

- [Código de Conduta](#código-de-conduta)
- [Como Contribuir](#como-contribuir)
- [Processo de Desenvolvimento](#processo-de-desenvolvimento)
- [Padrões de Código](#padrões-de-código)
- [Testes](#testes)
- [Documentação](#documentação)
- [Reportando Bugs](#reportando-bugs)
- [Sugerindo Melhorias](#sugerindo-melhorias)

## 🤝 Código de Conduta

Este projeto segue o [Código de Conduta do Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).

### Nossos Compromissos

- Criar um ambiente acolhedor e inclusivo
- Respeitar diferentes pontos de vista e experiências
- Aceitar críticas construtivas graciosamente
- Focar no que é melhor para a comunidade
- Demonstrar empatia com outros membros da comunidade

## 🚀 Como Contribuir

### 1. Fork e Clone

```bash
# Fork o repositório no GitHub
# Clone seu fork
git clone https://github.com/SEU_USUARIO/Game.Servers.git
cd Game.Servers

# Adicionar upstream
git remote add upstream https://github.com/ORIGINAL/Game.Servers.git
```

### 2. Criar Branch

```bash
# Criar branch para sua feature
git checkout -b feature/nova-feature

# Ou para correção de bug
git checkout -b fix/correcao-bug
```

### 3. Fazer Mudanças

- Siga os [padrões de código](#padrões-de-código)
- Adicione testes quando apropriado
- Atualize documentação se necessário
- Faça commits pequenos e focados

### 4. Testar

```bash
# Testar Terraform
cd terraform
terraform init
terraform plan

# Testar Ansible
cd ../ansible
ansible-playbook --check playbooks/deploy-game.yml

# Executar testes
./scripts/test.sh
```

### 5. Commit e Push

```bash
# Adicionar mudanças
git add .

# Commit com mensagem descritiva
git commit -m "feat: adiciona suporte para novo jogo"

# Push para seu fork
git push origin feature/nova-feature
```

### 6. Pull Request

- Abra um Pull Request no GitHub
- Descreva claramente as mudanças
- Referencie issues relacionadas
- Aguarde revisão e feedback

## 🔄 Processo de Desenvolvimento

### Workflow

1. **Issue**: Crie uma issue descrevendo o problema ou feature
2. **Branch**: Crie uma branch baseada na issue
3. **Desenvolvimento**: Implemente as mudanças
4. **Testes**: Execute todos os testes
5. **Pull Request**: Abra um PR para revisão
6. **Revisão**: Aguarde revisão e feedback
7. **Merge**: Após aprovação, o PR é mergeado

### Tipos de Branch

- `feature/`: Novas funcionalidades
- `fix/`: Correções de bugs
- `docs/`: Mudanças na documentação
- `refactor/`: Refatoração de código
- `test/`: Adição de testes
- `chore/`: Tarefas de manutenção

## 📝 Padrões de Código

### Terraform

```hcl
# Use nomes descritivos
resource "digitalocean_droplet" "game_server" {
  name = "${var.server_name}-${var.game_type}"
  # ...
}

# Comente código complexo
# Configurar firewall específico para o jogo
resource "digitalocean_firewall" "game_firewall" {
  # ...
}

# Use variáveis para valores configuráveis
variable "instance_size" {
  description = "Tamanho da instância"
  type        = string
  default     = "s-2vcpu-8gb"
}
```

### Ansible

```yaml
# Use nomes descritivos para tasks
- name: Instalar dependências específicas do jogo
  apt:
    name: "{{ item }}"
    state: present
  loop: "{{ game_dependencies }}"

# Comente tasks complexas
- name: Configurar serviço systemd
  # Esta task configura o serviço para auto-start
  template:
    src: "{{ game_type }}-server.service.j2"
    dest: "/etc/systemd/system/{{ game_type }}-server.service"
```

### Git Commits

Use o padrão [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: adiciona suporte para Valheim
fix: corrige problema de conectividade SSH
docs: atualiza documentação do Minecraft
refactor: melhora estrutura dos módulos Terraform
test: adiciona testes para role do SotF
chore: atualiza dependências do Ansible
```

### Mensagens de Commit

- Use imperativo ("adiciona" não "adicionado")
- Seja conciso mas descritivo
- Limite a primeira linha a 50 caracteres
- Use corpo para explicar o "porquê" se necessário

## 🧪 Testes

### Testes de Terraform

```bash
# Validar sintaxe
terraform validate

# Verificar formatação
terraform fmt -check

# Planejar mudanças
terraform plan
```

### Testes de Ansible

```bash
# Verificar sintaxe
ansible-playbook --syntax-check playbooks/deploy-game.yml

# Executar em modo check
ansible-playbook --check playbooks/deploy-game.yml

# Executar lint
ansible-lint playbooks/ roles/
```

### Testes de Integração

```bash
# Executar suite completa de testes
./scripts/test-integration.sh

# Testar deploy de um jogo específico
./scripts/test-deploy.sh minecraft
```

## 📚 Documentação

### Atualizar Documentação

- Mantenha documentação atualizada com mudanças
- Use linguagem clara e concisa
- Inclua exemplos quando apropriado
- Atualize README se necessário

### Estrutura de Documentação

```
docs/
├── sotf-setup.md          # Setup específico do SotF
├── minecraft-setup.md     # Setup específico do Minecraft
├── architecture.md        # Arquitetura do sistema
├── adding-games.md        # Como adicionar novos jogos
├── troubleshooting.md     # Resolução de problemas
└── architecture-diagram.md # Diagramas da arquitetura
```

### Padrões de Documentação

- Use Markdown
- Inclua exemplos de código
- Mantenha estrutura consistente
- Atualize índices quando adicionar conteúdo

## 🐛 Reportando Bugs

### Antes de Reportar

1. Verifique se o bug já foi reportado
2. Teste com a versão mais recente
3. Verifique a documentação
4. Consulte o troubleshooting

### Como Reportar

Use o template de issue:

```markdown
**Descrição do Bug**
Uma descrição clara e concisa do bug.

**Passos para Reproduzir**
1. Vá para '...'
2. Clique em '...'
3. Veja o erro

**Comportamento Esperado**
O que deveria acontecer.

**Screenshots**
Se aplicável, adicione screenshots.

**Informações do Sistema**
- OS: [ex: Ubuntu 22.04]
- Terraform: [ex: 1.5.0]
- Ansible: [ex: 6.0.0]
- Jogo: [ex: Sons of the Forest]

**Logs**
Inclua logs relevantes.

**Contexto Adicional**
Qualquer outra informação relevante.
```

## 💡 Sugerindo Melhorias

### Antes de Sugerir

1. Verifique se a melhoria já foi sugerida
2. Considere se é realmente necessária
3. Pense em como implementar
4. Considere o impacto na arquitetura

### Como Sugerir

Use o template de feature request:

```markdown
**Funcionalidade Solicitada**
Uma descrição clara e concisa da funcionalidade.

**Problema que Resolve**
Descreva o problema que esta funcionalidade resolveria.

**Solução Proposta**
Descreva como você gostaria que funcionasse.

**Alternativas Consideradas**
Descreva alternativas que você considerou.

**Contexto Adicional**
Qualquer outra informação relevante.
```

## 🎮 Adicionando Novos Jogos

### Processo

1. **Criar Issue**: Descreva o jogo e requisitos
2. **Implementar**: Siga o [guia de adicionar jogos](./docs/adding-games.md)
3. **Testar**: Execute testes completos
4. **Documentar**: Crie documentação específica
5. **Pull Request**: Submeta para revisão

### Checklist

- [ ] Adicionar portas no módulo firewall
- [ ] Criar role Ansible específica
- [ ] Atualizar validações do Terraform
- [ ] Adicionar documentação
- [ ] Criar testes
- [ ] Atualizar README
- [ ] Atualizar CHANGELOG

## 🔧 Configuração de Desenvolvimento

### Pré-requisitos

```bash
# Instalar dependências
./scripts/setup.sh

# Ou no Windows
./scripts/setup.ps1
```

### Ambiente de Desenvolvimento

```bash
# Configurar variáveis de ambiente
export TF_VAR_do_token="seu-token"
export TF_VAR_ssh_key_id="seu-ssh-key-id"

# Inicializar Terraform
cd terraform
terraform init

# Configurar Ansible
cd ../ansible
ansible-playbook --check playbooks/deploy-game.yml
```

## 📞 Suporte

### Recursos

- **Documentação**: [docs/](./docs/)
- **Issues**: [GitHub Issues](https://github.com/ORIGINAL/Game.Servers/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ORIGINAL/Game.Servers/discussions)
- **Discord**: [Link para Discord]

### Contato

- **Email**: [Seu email]
- **Twitter**: [@SeuTwitter]
- **LinkedIn**: [Seu LinkedIn]

## 📄 Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a [Licença MIT](LICENSE).

## 🙏 Agradecimentos

Obrigado a todos os contribuidores que ajudaram a tornar este projeto possível!

---

**Nota**: Este guia é um documento vivo e será atualizado conforme necessário. Se você tiver sugestões para melhorá-lo, abra uma issue ou pull request!
