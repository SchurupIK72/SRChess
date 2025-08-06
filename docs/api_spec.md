# API-спецификация для MVP приложения «Шахматы с особыми правилами»

## ✅ Общие сведения

- **Базовый URL REST**: `https://your-domain.com/api`
- **Базовый URL WebSocket**: `wss://your-domain.com/ws/match/{match_id}`
- **Аутентификация**: JWT (`Authorization: Bearer <token>`)

---

## 🔐 Аутентификация

### POST /auth/register
**Описание**: регистрация нового пользователя  
**Тело запроса**:
```json
{
  "username": "newPlayer",
  "password": "secure123"
}
```
**Ответ 201**:
```json
{
  "access_token": "jwt_token_string",
  "token_type": "bearer"
}
```

### POST /auth/login
**Описание**: вход в систему  
**Тело запроса**:
```json
{
  "username": "newPlayer",
  "password": "secure123"
}
```
**Ответ 200**:
```json
{
  "access_token": "jwt_token_string",
  "token_type": "bearer"
}
```

---

## 🎮 Матчи

### GET /matches
**Описание**: получить список доступных матчей  
**Ответ 200**:
```json
[
  {
    "id": "match123",
    "players": ["player1"],
    "status": "waiting",
    "rules": ["DoubleKnight"]
  }
]
```

### POST /matches
**Описание**: создать новую игру  
**Тело запроса**:
```json
{
  "rules": ["XRay", "Blink"]
}
```
**Ответ 201**:
```json
{
  "id": "match123",
  "status": "waiting"
}
```

### GET /matches/{id}
**Описание**: получить данные конкретного матча  
**Ответ 200**:
```json
{
  "id": "match123",
  "players": ["player1", "player2"],
  "board": [[...], [...]],
  "turn": "white",
  "history": ["e2e4", "e7e5"],
  "rules": ["XRay"]
}
```

---

## 🧾 История партий

### GET /history
**Описание**: получить список завершённых игр текущего пользователя  
**Ответ 200**:
```json
[
  {
    "id": "match001",
    "opponent": "enemyMaster",
    "result": "win",
    "moves": ["e2e4", "e7e5", "..."]
  }
]
```

---

## 🔄 WebSocket: `wss://your-domain.com/ws/match/{match_id}`

### 💬 Формат сообщений клиента:

#### 1. move
```json
{
  "type": "move",
  "from": "e2",
  "to": "e4"
}
```

#### 2. chat
```json
{
  "type": "chat",
  "message": "Good luck!"
}
```

#### 3. resign
```json
{
  "type": "resign"
}
```

#### 4. rules_change
```json
{
  "type": "rules_change",
  "rules": ["XRay", "DoubleKnight"]
}
```

---

### 🧠 Пример ответа сервера

```json
{
  "type": "state",
  "board": [[...], [...]],
  "turn": "black",
  "history": ["e2e4", "e7e5"],
  "rules": ["XRay"],
  "status": "active",
  "players": ["whiteUser", "blackUser"]
}
```

---

## ⚠️ Ошибки

| Код | Значение            |
|-----|---------------------|
| 400 | Неверные данные     |
| 401 | Неавторизован       |
| 403 | Доступ запрещён     |
| 404 | Матч не найден      |
| 409 | Конфликт (игра началась и т.п.) |
