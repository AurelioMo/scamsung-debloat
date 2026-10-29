# Presets

Três arquivos, cada um autocontido. Cada linha é **um pacote** + o que ele é / o que
quebra se sair:

```
com.facebook.katana   # Facebook
^pacote               ^ explicação
```

| Preset | Pacotes | Para quem |
|--------|--------:|-----------|
| `basic.txt` | 113 | quer o mínimo de risco; mantém conta Samsung, Galaxy AI e Health |
| `light.txt` | 193 | não usa conta Samsung nem recursos Galaxy; inclui o basic |
| `heavy.txt` | 264 | quer o máximo reversível; inclui o light |

`heavy` contém tudo de `light`, que contém tudo de `basic` — o `self-test` falha se isso
quebrar.

## Formato

- `#` até o fim da linha é comentário; o texto depois de `#` é a explicação do pacote.
- Toda linha de pacote **precisa** de explicação; sem ela o `self-test` falha.
- Linha em branco é ignorada. Pacote repetido no mesmo arquivo é erro.
- Pacote da deny-list no arquivo é erro (a deny-list fica no `scamsung`, em `is_denied()`).

## Usar

```bash
./scamsung list
./scamsung -n apply light   # prévia
./scamsung apply light
./scamsung explain com.facebook.katana
./scamsung restore
```

## Editar

1. Descubra o nome: `./scamsung scan <termo>` ou `adb shell pm list packages | grep termo`.
2. Adicione a linha no preset certo, com explicação em pt-BR.
3. Rode `./scamsung self-test` e depois `./scamsung -n apply <preset>`.

Se o pacote for crítico (telefone, SMS, teclado, launcher, Play Services, IMS, Knox de
container), **não adicione**: coloque em `is_denied()` no script. A deny-list é a última
barreira antes de qualquer ação.
