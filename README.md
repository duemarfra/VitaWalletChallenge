# Vita Wallet Challenge

Esta es una guia de uso de la api creada para el Challenge de ingreso como developer en "Vita Wallet"

## 1 LISTA DE USUARIOS http://localhost:3000/users

Esta es una ruta libre que lista todos los usuarios de nuestra aplicacion

se puede acceder a esta mediante curl:

```bash
curl -X GET http://localhost:3000/users
```

o de esta forma en postman:

1. Abre Postman.
2. Crea una nueva solicitud.
3. Configura el método HTTP como GET.
4. Introduce la URL: http://localhost:3000/users.
5. Haz clic en "Send" para obtener la respuesta.

## 2 CREAR UN USUARIO http://localhost:3000/users

Esta es una ruta libre que crea un usuario en nuestra aplicacion

se puede acceder a esta mediante curl:

```bash
curl -X POST http://localhost:3000/users \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "nuevo_usuario@test.com",
    "password": "password123"
  }
}'

```

o de esta forma en postman:

1. En nueva solicitud.
2. Configura el método HTTP como POST.
3. Introduce la URL: http://localhost:3000/users.
4. En la pestaña "Body", selecciona raw y elige JSON como formato.
5. Introduce el siguiente cuerpo de solicitud:

```bash
{
  "user": {
    "email": "nuevo_usuario@test.com",
    "password": "password123"
  }
}

```

6. Haz clic en "Send" para crear el usuario.

## 3 INICIAR SESIÓN Y OBTENER UN TOKEN DE SESIÓN http://localhost:3000/users/sign_in

Esta es una ruta que para usarla debemos haber creado previamente un **USUARIO** como lo detallamos anterior mente ya que necesitamos el email y contraseña de este.

se puede acceder a esta mediante curl:

```bash
curl -X POST http://localhost:3000/users/sign_in \
-H "Content-Type: application/json" \
-d '{
  "email": "nuevo_usuario@test.com",
  "password": "password123"
}'
```

o de esta forma en postman:

1. En una nueva solicitud.
2. Configura el método HTTP como POST.
3. Introduce la URL: http://localhost:3000/users/sign_in.
4. En la pestaña "Body", selecciona raw y elige JSON como formato.
5. Introduce el siguiente cuerpo de solicitud:

```bash
{
  "email": "test1@test.com",
  "password": "123456"
}

```

6. Haz clic en "Send".

La respuesta obtenida mediante cualquiera de los 2 metodos serán los datos del usuario y entre ellos el **"session_token"** el cual debemos tenerlo presente para conectarnos a algunos los futuros metodos:

```bash

{
  "message": "User signed_in successfully",
  "user": {
    "session_token": "+X+pnr7CElT29FZW2KPClH3/WEH9M7bKGnUhAL8Eca1yP6KMZzSjo8c//j8j30Ze/RwqzZ73Gs+wQGuayA2mUA==",
    "id": 1,
    "usd_balance": "0.0",
    "btc_balance": "0.0",
    "email": "nuevo_usuario@test.com",
    "password_digest": "$2a$12$7gFnt7ZP8QFn2cddit9LN.OS4HdqywrA/2GP5/efLI3Bsa/u6vZ8.",
    "created_at": "2025-01-19T14:31:55.239Z",
    "updated_at": "2025-01-19T14:53:30.013Z"
  }
}

```

## 4 Fondear una cuenta http://localhost:3000/users/1/fund_account

Esta es una ruta que necesita el **id del usuario (users/id/)** y tambien el **token de inicio de sesion** del usaurio.

Este metodo si bien no es necesario en el enunciado del challenge nos sirve para manipular los montos de nuestras cuentas de "usd" y "btc" como simulacro de transferencias de ingreso o egreso.

se puede acceder a esta mediante curl:

```bash
curl -X PUT http://localhost:3000/users/1/fund_account \
-H "Authorization: Bearer +X+pnr7CElT29FZW2KPClH3/WEH9M7bKGnUhAL8Eca1yP6KMZzSjo8c//j8j30Ze/RwqzZ73Gs+wQGuayA2mUA==" \
-H "Content-Type: application/json" \
-d '{
  "currency": "btc",
  "amount": 0.1
}'
```

o de esta forma en postman:

1. Método: PUT
2. URL: http://localhost:3000/users/1/fund_account
3. Headers:

   Key: Authorization
   Value: Bearer +X+pnr7CElT29FZW2KPClH3/WEH9M7bKGnUhAL8Eca1yP6KMZzSjo8c//j8j30Ze/RwqzZ73Gs+wQGuayA2mUA==
   Key: Content-Type
   Value: application/json

4. Body:

   Selecciona raw como tipo de entrada.
   Ingresa el cuerpo en formato JSON:

```bash
{
  "currency": "btc",
  "amount": 0.1
}
```

La respuesta obtenida mediante cualquiera de los 2 metodos serán:

```bash
{
  "message": "Funds added",
  "user": {
    "email": "nuevo_usuario@test.com",
    "previous_balance": "BTC: 0,00000000",
    "amount": "+ 0.1",
    "current_balance": "BTC: 0,10000000"
  }
}
```

## 5 Consultar los precios de btc en usd, gbo y eur http://localhost:3000/btc_price

Esta es una ruta de un metodo interno que se conecta al servicio de coindesk

se puede acceder a esta mediante curl:

```bash
curl -X GET http://localhost:3000/btc_price
```

o de esta forma en postman:

1. Abre Postman.
2. Crea una nueva solicitud.
3. Configura el método HTTP como GET.
4. Introduce la URL: http://localhost:3000/btc_price.
5. Haz clic en "Send" para obtener la respuesta.

La respuesta obtenida mediante cualquiera de los 2 metodos serán:

```bash
{
    "message":"BTC Prices in different currencies",
    "data":{
        "usd":106275.568,
        "gbp":84762.7361,
        "eur":102208.8271
    }
}
```

## 6 Lista las TODAS las transacciones de un usuario http://localhost:3000/users/1/transactions

Esta es una ruta que necesita el **id del usuario (users/id/)** y tambien el **token de inicio de sesion** del usaurio.

se puede acceder a esta mediante curl:

```bash
curl -X GET http://localhost:3000/users/1/transactions \
-H "Authorization: Bearer +X+pnr7CElT29FZW2KPClH3/WEH9M7bKGnUhAL8Eca1yP6KMZzSjo8c//j8j30Ze/RwqzZ73Gs+wQGuayA2mUA=="
```

o de esta forma en postman:

1. Método: GET
2. URL: http://localhost:3000/users/1/transactions
3. Headers:

   Key: Authorization
   Value: Bearer +X+pnr7CElT29FZW2KPClH3/WEH9M7bKGnUhAL8Eca1yP6KMZzSjo8c//j8j30Ze/RwqzZ73Gs+wQGuayA2mUA==

4.Haz clic en "Send" para obtener la lista de transacciones asociadas al usuario.

La respuesta obtenida mediante cualquiera de los 2 metodos serán:

```bash
{
    "transactions": [
        {
            "id": 1,
            "is_buy": false,
            "amount_sent": "0.1",
            "amount_received": "10607.69",
            "user_id": 1,
            "created_at": "2025-01-19T16:01:49.273Z",
            "updated_at": "2025-01-19T16:01:49.273Z"
        },
        {
            "id": 2,
            "is_buy": true,
            "amount_sent": "10600.0",
            "amount_received": "0.0998238",
            "user_id": 1,
            "created_at": "2025-01-19T16:07:55.780Z",
            "updated_at": "2025-01-19T16:07:55.780Z"
        }
    ]
}
```

## 7 Lista las UNA de las transacciones de un usuario http://localhost:3000/users/1/transactions/1

Esta es una ruta que necesita el **id del usuario (users/id/)** y el **id de la transaccion (transactions/id/)** y tambien el **token de inicio de sesion** del usaurio.

se puede acceder a esta mediante curl:

```bash
curl -X GET http://localhost:3000/users/1/transactions/1 \
-H "Authorization: Bearer +X+pnr7CElT29FZW2KPClH3/WEH9M7bKGnUhAL8Eca1yP6KMZzSjo8c//j8j30Ze/RwqzZ73Gs+wQGuayA2mUA=="
```

o de esta forma en postman:

1. Método: GET
2. URL: http://localhost:3000/users/1/transactions/1
3. Headers:

   Key: Authorization
   Value: Bearer +X+pnr7CElT29FZW2KPClH3/WEH9M7bKGnUhAL8Eca1yP6KMZzSjo8c//j8j30Ze/RwqzZ73Gs+wQGuayA2mUA==

4.Haz clic en "Send" para obtener la lista de transacciones asociadas al usuario.

La respuesta obtenida mediante cualquiera de los 2 metodos serán:

```bash
{
    "transaction": {
        "id": 1,
        "is_buy": false,
        "amount_sent": "0.1",
        "amount_received": "10607.69",
        "user_id": 1,
        "created_at": "2025-01-19T16:01:49.273Z",
        "updated_at": "2025-01-19T16:01:49.273Z"
    }
}
```

## 8 Crear una Transaccion http://localhost:3000/users/1/transactions

Para crear una transaccion necesitamos el **id del usuario (users/id/)** y tambien el **token de inicio de sesion** (+X+pnr7CElT29FZW2KPClH3/WEH9M7bKGnUhAL8Eca1yP6KMZzSjo8c//j8j30Ze/RwqzZ73Gs+wQGuayA2mUA==) del usaurio.

se puede acceder a esta mediante curl (POST):

```bash
curl -X POST http://localhost:3000/users/1/transactions \
-H "Authorization: Bearer +X+pnr7CElT29FZW2KPClH3/WEH9M7bKGnUhAL8Eca1yP6KMZzSjo8c//j8j30Ze/RwqzZ73Gs+wQGuayA2mUA==" \
-H "Content-Type: application/json" \
-d '{
  "is_buy": "false",
  "amount_sent": 0.1
}'

```

o de esta forma en postman:

1. Método: POST
2. URL: http://localhost:3000/users/1/transactions
3. Headers:

   Key: Authorization
   Value: Bearer +X+pnr7CElT29FZW2KPClH3/WEH9M7bKGnUhAL8Eca1yP6KMZzSjo8c//j8j30Ze/RwqzZ73Gs+wQGuayA2mUA==
   Key: Content-Type
   Value: application/json

4. Body:

   Tipo: raw
   JSON:

```bash
{
  "is_buy": "true",
  "amount_sent": 31000
}

```

5. Haz clic en "Send" para crear la transacción.

La respuesta obtenida mediante cualquiera de los 2 metodos serán:

```bash
{
    "message":"Transaction completed successfully.",
    "transaction":{
        "is_buy":false,
        "amount_sent":"BTC: 0,10",
        "amount_received":"USD: 10607,69"
    }
}
```
