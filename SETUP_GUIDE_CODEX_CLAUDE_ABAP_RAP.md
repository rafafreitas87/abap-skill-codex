# Setup Guide: Codex/Claude para ABAP RAP com ADT MCP, ARC-1 e Skills

Este guia prepara uma maquina Windows para trabalhar com ABAP RAP usando:

- SAP ABAP Development Tools (Eclipse) ou VS Code
- MCP oficial ADT exposto em `http://127.0.0.1:2236/mcp`
- ARC-1 para leitura/escrita de objetos ABAP via ADT
- Skill Codex `abap-rap-adt`
- Sistema S/4HANA lab `S4H` client `100`

Nao salve senha em arquivos. A senha SAP deve ser informada na sessao ou em variavel de ambiente temporaria.

## 1. Pre-requisitos

Instale:

- Git
- Node.js LTS com `npm`
- Visual Studio Code
- Eclipse com ABAP Development Tools, se preferir trabalhar pelo Eclipse
- Codex CLI ou Claude Code, conforme o assistente usado

Verifique:

```powershell
git --version
node --version
npm --version
```

## 2. Conexao SAP no Eclipse ou VS Code

Antes de configurar Codex/Claude, o ambiente de desenvolvimento precisa ter ABAP ADT instalado e uma destination/projeto ADT criada. O MCP oficial ADT e o ARC-1 dependem dessa base funcionando.

Crie uma conexao ADT para o sistema:

- Host/IP: `20.62.45.108`
- Porta HTTPS: `44300`
- Client: `100`
- User: `MGLDEV01`
- Destination esperada no MCP: `S4H_100_MGLDEV01_EN`

No Eclipse:

1. Instale ABAP Development Tools.
2. Crie um ABAP Project apontando para o host/porta/client acima.
3. Faca login com o usuario SAP.
4. Salve a conexao/destination ADT.
5. Confirme que consegue abrir o pacote de trabalho, por exemplo `ZTRF01004`.

No VS Code:

1. Instale a extensao/ferramenta ABAP ADT usada pelo time.
2. Configure a mesma conexao/destination ADT.
3. Faca login com o usuario SAP.
4. Confirme que consegue navegar pelo pacote ABAP.
5. Inicie o servidor MCP ADT oficial se a extensao/ferramenta exigir uma acao manual.

O Codex nesta maquina espera o MCP ADT em:

```toml
[mcp_servers.adt]
url = "http://127.0.0.1:2236/mcp"
bearer_token_env_var = "ADT_MCP_TOKEN"
enabled = true
startup_timeout_sec = 20
tool_timeout_sec = 60
```

Se o servidor ADT MCP exigir token, defina `ADT_MCP_TOKEN` antes de iniciar Codex/Claude.

## 3. Instalar ARC-1

ARC-1 e um MCP/CLI para SAP ABAP. Instale via npm:

```powershell
npm install -g arc-1
arc1 --help
```

Configure as variaveis de ambiente para a sessao PowerShell:

```powershell
$env:SAP_URL='https://20.62.45.108:44300'
$env:SAP_CLIENT='100'
$env:SAP_USER='MGLDEV01'
$env:SAP_PASSWORD='<NAO_COMMITAR_SENHA>'
$env:SAP_INSECURE='true'
```

Para permitir escrita, informe tambem o pacote e transporte do trabalho atual:

```powershell
$env:SAP_ALLOW_WRITES='true'
$env:SAP_ALLOWED_PACKAGES='ZTRF01004'
$env:SAP_ALLOWED_TRANSPORTS='S4HK903338'
```

Teste leitura:

```powershell
arc1 call SAPRead --arg type=DEVC --arg name=ZTRF01004
```

Ou leia um objeto conhecido:

```powershell
arc1 read DDLS ZTRF_C_EC_ORDER
```

## 4. Configurar Codex com MCP ADT

Edite `%USERPROFILE%\.codex\config.toml` e inclua:

```toml
[mcp_servers.adt]
url = "http://127.0.0.1:2236/mcp"
bearer_token_env_var = "ADT_MCP_TOKEN"
enabled = true
startup_timeout_sec = 20
tool_timeout_sec = 60
```

Reinicie o Codex depois de alterar o config.

Checklist no Codex:

- A skill `abap-rap-adt` aparece na lista de skills.
- O MCP ADT aparece como servidor ativo.
- As ferramentas ADT estao disponiveis, por exemplo:
  - transporte
  - business services
  - activation
  - generators

## 5. Configurar Claude Code com MCP ADT

Claude Code pode usar MCP por arquivo `.mcp.json` de projeto ou por comando `claude mcp`.

Exemplo de `.mcp.json` no projeto:

```json
{
  "mcpServers": {
    "adt": {
      "type": "http",
      "url": "http://127.0.0.1:2236/mcp",
      "headers": {
        "Authorization": "Bearer ${ADT_MCP_TOKEN}"
      }
    }
  }
}
```

Se o MCP ADT local nao usar token, remova o header ou ajuste conforme a ferramenta ADT instalada.

Valide no Claude:

```powershell
claude mcp list
```

Para Claude, as skills Codex nao sao carregadas automaticamente como skills nativas. Use uma destas opcoes:

- copie o conteudo essencial de `abap-rap-adt/SKILL.md` para `CLAUDE.md` do projeto;
- ou peca explicitamente: `Use o guia em abap-rap-adt/SKILL.md para trabalhar com RAP ABAP`.

## 6. Instalar a Skill Codex

Clone este repositorio:

```powershell
git clone https://github.com/rafafreitas87/abap-skill-codex.git
```

Copie a skill para o diretorio de skills do Codex:

```powershell
$src = ".\abap-skill-codex\abap-rap-adt"
$dst = "$env:USERPROFILE\.codex\skills\abap-rap-adt"
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
Copy-Item $src $dst -Recurse
```

Reinicie Codex.

Quando iniciar um trabalho RAP, diga algo como:

```text
Use a skill abap-rap-adt. Sistema S4H client 100, pacote ZTRF01004, transporte S4HK903338.
Antes de escrita ARC-1, confirme SAP_PASSWORD na sessao.
```

## 7. Padrao de Variaveis para Trabalhos RAP

Antes de criar/alterar objetos ABAP com ARC-1:

```powershell
$env:SAP_URL='https://20.62.45.108:44300'
$env:SAP_CLIENT='100'
$env:SAP_USER='MGLDEV01'
$env:SAP_PASSWORD='<SENHA_DA_SESSAO>'
$env:SAP_INSECURE='true'
$env:SAP_ALLOW_WRITES='true'
$env:SAP_ALLOWED_PACKAGES='<PACOTE>'
$env:SAP_ALLOWED_TRANSPORTS='<TRANSPORTE>'
```

Nunca coloque a senha em:

- `SKILL.md`
- `.mcp.json`
- `config.toml`
- payload JSON commitado
- README/guia publico
- historico de commit

## 8. Padroes RAP que o Assistente deve seguir

Para novos RAPs ZTRF:

- usar managed RAP por padrao;
- usar draft por padrao;
- usar OData V4 UI service por padrao;
- criar persistence table, draft table, CDS root/interface, CDS projection, BDEF root/projection, behavior pool, DDLX, SRVD e SRVB;
- ativar em pequenos lotes e corrigir erros de ativacao imediatamente;
- publicar service binding depois da ativacao;
- verificar service metadata com ADT MCP ou HTTP.

Para itens de composicao:

- deixar RAP draft/composition controlar a criacao;
- se precisar item default, usar `use create ( augment )` na projection BDEF;
- criar projection behavior class para o augment;
- usar `MODIFY AUGMENTING ENTITIES`;
- usar unidade default `EA`;
- cuidar para late numbering de filhos nao repetir `0001` para varios itens no mesmo draft.

Para campos calculados:

- tornar valores calculados readonly no BDEF;
- nao disparar determinacao por um campo que a propria determinacao atualiza;
- calcular total do header a partir dos itens;
- validar material antes de salvar item;
- usar value help estavel para materiais.

Para action em tela inicial:

- action no root BDEF;
- implementacao no behavior pool;
- `use action` na projection BDEF;
- `@UI.lineItem` com `type: #FOR_ACTION`.

## 9. Troubleshooting

Se o MCP ADT nao aparecer:

- confirme que o servidor ADT MCP esta rodando em `127.0.0.1:2236`;
- confirme `ADT_MCP_TOKEN`, se aplicavel;
- reinicie VS Code/Eclipse e Codex/Claude.

Se ARC-1 bloquear escrita:

- confirme `SAP_ALLOW_WRITES=true`;
- confirme `SAP_ALLOWED_PACKAGES`;
- confirme `SAP_ALLOWED_TRANSPORTS`;
- confirme `SAP_PASSWORD` na sessao;
- confirme `SAP_INSECURE=true` para o certificado do lab.

Se o linter ARC-1 rejeitar classes `FOR BEHAVIOR OF`:

- use payload com `lintBeforeWrite: false`.

Se itens somem em draft:

- verifique chaves temporarias/late numbering de item;
- evite criar varios filhos com o mesmo `ItemID`;
- evite determinacoes que reescrevem a colecao durante a criacao da UI.

## 10. Smoke Test Final

1. Codex/Claude consegue listar ferramentas MCP ADT.
2. ARC-1 consegue ler um objeto SAP.
3. ARC-1 consegue ativar ou diagnosticar sintaxe de um objeto permitido.
4. A skill `abap-rap-adt` e carregada pelo Codex.
5. O pacote alvo e o transporte sao confirmados antes de escrita.
6. Nenhuma senha foi salva em arquivo.

