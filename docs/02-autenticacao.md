# Autenticacao da API aaPanel

## Como funciona

A API do aaPanel usa um sistema de autenticacao baseado em **assinatura por timestamp**. Cada requisicao deve incluir dois parametros especiais.

## Parametros de autenticacao

| Parametro | Descricao | Como gerar |
|-----------|-----------|------------|
| `request_time` | Timestamp Unix atual | `date +%s` |
| `request_token` | Hash MD5 de verificacao | `md5(str(timestamp) + md5(api_key))` |

## Algoritmo

```
1. Obter timestamp atual (Unix epoch em segundos)
2. Calcular MD5 da API Key
3. Concatenar: str(timestamp) + md5(api_key)
4. Calcular MD5 do resultado
5. Enviar ambos como parametros POST
```

## Exemplo em Bash

```bash
API_KEY="b4uzdFJT7wJSqGnemqa1vRKhyrIKYeDp"
TIMESTAMP=$(date +%s)

# MD5 da API key
KEY_MD5=$(echo -n "$API_KEY" | md5sum | awk '{print $1}')

# Token = MD5(timestamp + key_md5)
TOKEN=$(echo -n "${TIMESTAMP}${KEY_MD5}" | md5sum | awk '{print $1}')

# Requisicao
curl -sk -X POST "https://168.231.92.99:17198/system?action=GetSystemTotal" \
  -d "request_time=${TIMESTAMP}&request_token=${TOKEN}"
```

## Exemplo em Python

```python
import hashlib
import time
import requests

API_KEY = "b4uzdFJT7wJSqGnemqa1vRKhyrIKYeDp"
BASE_URL = "https://168.231.92.99:17198"

def get_auth():
    timestamp = str(int(time.time()))
    key_md5 = hashlib.md5(API_KEY.encode()).hexdigest()
    token = hashlib.md5((timestamp + key_md5).encode()).hexdigest()
    return {"request_time": timestamp, "request_token": token}

# Uso
response = requests.post(
    f"{BASE_URL}/system?action=GetSystemTotal",
    data=get_auth(),
    verify=False  # SSL auto-assinado
)
print(response.json())
```

## Exemplo em TypeScript/Node.js

```typescript
import crypto from 'crypto';

const API_KEY = 'b4uzdFJT7wJSqGnemqa1vRKhyrIKYeDp';
const BASE_URL = 'https://168.231.92.99:17198';

function getAuth() {
  const timestamp = Math.floor(Date.now() / 1000).toString();
  const keyMd5 = crypto.createHash('md5').update(API_KEY).digest('hex');
  const token = crypto.createHash('md5').update(timestamp + keyMd5).digest('hex');
  return { request_time: timestamp, request_token: token };
}

// Uso
async function apiCall(endpoint: string, params: Record<string, string> = {}) {
  const auth = getAuth();
  const body = new URLSearchParams({ ...auth, ...params });

  const response = await fetch(`${BASE_URL}${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: body.toString(),
  });
  return response.json();
}
```

## Notas importantes

1. **IP Whitelist**: O IP da maquina chamadora DEVE estar na whitelist do painel
2. **HTTPS**: O servidor usa certificado auto-assinado — desabilite verificacao SSL
3. **Content-Type**: Sempre `application/x-www-form-urlencoded`
4. **Metodo**: Sempre `POST` (nunca GET)
5. **Cookies**: Salve cookies entre requisicoes para melhor performance
6. **Timeout**: Recomendado 30 segundos para operacoes normais
