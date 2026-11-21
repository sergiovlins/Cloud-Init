# Evidências

Prints salvos em `docs/prints/`.

## 1. Preparação

Geração da chave SSH, consulta do IP público e criação do bucket para o state do Terraform. O print mostra duas tentativas com erro antes da criação do bucket

![Chave SSH e bucket](prints/01-chave-ssh-e-bucket.png)

Criação do `terraform.tfvars` com a chave pública e o IP liberado para SSH. O arquivo não é enviado ao repositório (`.gitignore`).

![terraform.tfvars](prints/02-tfvars.png)

## 2. Validação e plano (local)

Primeira execução: `init` concluído, `fmt -check` apontando o `terraform.tfvars` e `validate` com erro no nome do security group.

![Erro no fmt e validate](prints/03-erro-fmt-e-validate.png)

![Erro no plan](prints/04-erro-plan.png)

Após as correções, `fmt -check` sem pendências e `validate` com sucesso.

![fmt e validate](prints/05-fmt-validate-ok.png)

Plano de execução: criação de 3 recursos = key pair, security group e instância `t3.micro` com Ubuntu 24.04. A AMI é apenas consultada (`data source`).

![Plan](prints/06-plan-ok.png)

## 3. Pipeline executada

Execução manual concluída com sucesso: jobs `plan` e `apply` e aprovação no environment `producao`.

![Execução da pipeline](prints/07-pipeline.png)

Etapas fmt, init, validate e plan do job `plan`.

![Job plan](prints/08-job-plan.png)

Saída do job `apply` com o IP público.

![Job apply](prints/09-job-apply.png)

## 4. Infraestrutura provisionada

Instância `vm-cloud-init` em execução no console EC2 (us-east-2), com 3/3 verificações aprovadas.

![Console EC2](prints/10-ec2.png)

Acesso à VM por SSH com a chave cadastrada pelo Terraform.

![Acesso SSH](prints/11-ssh.png)

## 5. Cloud-Init concluído

```bash
cloud-init status --long
hostnamectl
tail -n 5 /var/log/cloud-init-output.log
```

Status `done` sem erros, hostname `vm-cloud-init` e mensagem final do Cloud-Init no log.

![Status do Cloud-Init](prints/12-cloud-init.png)

## 6. Docker e Nginx ativos

```bash
systemctl is-active docker nginx
docker --version && nginx -v
docker run --rm hello-world
```

![Serviços ativos](prints/13-servicos.png)

Primeira tentativa de acesso pelo navegador com erro por configurações do navegador, que forçava a conexão para HTTPS.

![Erro HTTPS](prints/14-erro-https.png)

Página do Nginx acessada em `http://3.131.158.216`.

![Nginx no navegador](prints/15-nginx.png)

## 7. Recursos destruídos

Saída do `terraform destroy`.

![Destroy](prints/16-destroy.png)
