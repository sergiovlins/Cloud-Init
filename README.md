# Terraform + Cloud-Init + GitHub Actions

Provisiona uma VM Ubuntu 24.04 na AWS (EC2 `t3.micro`) e a configura no primeiro boot com Cloud-Init: hostname, `apt update`, instalação e inicialização do Docker e do Nginx. Uma pipeline no GitHub Actions valida o código e aplica a infraestrutura somente com aprovação manual.

## Estrutura

```
.
├── .github/workflows/terraform.yml   # Pipeline CI/CD
├── docs/EVIDENCIAS.md                # Evidências
├── main.tf                           # provider, backend S3, security group e instância
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── user-data.yaml                    # configuração inicial da VM
└── .gitignore
```

## Pré-requisitos

- Conta AWS, AWS CLI e Terraform >= 1.10
- Usuário IAM com chave de acesso (`aws configure`)
- Par de chaves SSH (`ssh-keygen -t ed25519`)
- Bucket S3 para o state, na região `us-east-1`:

```bash
aws s3 mb s3://NOME-UNICO-DO-BUCKET --region us-east-1
```

Depois, trocar `NOME-DO-SEU-BUCKET` no `main.tf` pelo nome criado.

## Execução local

```bash
cp terraform.tfvars.example terraform.tfvars   # preencher chave pública e IP
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

## Pipeline

| Evento | O que executa |
|---|---|
| `push` / `pull_request` | fmt, init, validate, plan |
| Execução manual (Run workflow) | etapas acima + apply, após aprovação |

Configuração em **Settings** do repositório:

| Onde | Nome | Valor |
|---|---|---|
| Secrets and variables → Secrets | `AWS_ACCESS_KEY_ID` | chave de acesso do usuário IAM |
| Secrets and variables → Secrets | `AWS_SECRET_ACCESS_KEY` | chave secreta do usuário IAM |
| Secrets and variables → Variables | `SSH_PUBLIC_KEY` | conteúdo de `~/.ssh/id_ed25519.pub` |
| Secrets and variables → Variables | `SSH_CIDR` | seu IP com `/32` (`curl ifconfig.me`) |
| Environments | `producao` | marcar *Required reviewers* com seu usuário |

Para aplicar: **Actions → Terraform → Run workflow**, aguardar o plan e aprovar o job `apply`.

## Validação na VM

```bash
ssh ubuntu@IP_PUBLICO
cloud-init status --long
hostnamectl
systemctl is-active docker nginx
docker --version && nginx -v
docker run --rm hello-world
curl -s localhost
```

## Destruir

```bash
terraform destroy
```

## Segurança

- Credenciais apenas em GitHub Secrets; `*.tfvars` e `*.tfstate` fora do repositório.
- SSH liberado só para o IP informado.
- Aplicação condicionada a aprovação no environment `producao`.
