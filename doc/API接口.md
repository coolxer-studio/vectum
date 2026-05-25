# Task 任务接口文档

**基础信息**
- **模块名称**: 任务管理
- **基础路径**: `/vectum/api/v1/task`
- **作者**: hunter
- **协议**: HTTP/HTTPS
- **数据格式**: JSON

---

## 📋 数据模型定义

### 1. TaskDto (任务传输对象)

```json
{
  "id": 1,                    // Integer - 任务ID
  "name": "任务名称",          // String - 任务名
  "description": "任务描述",   // String - 描述信息
  "config": "{}",             // String - 配置(JSON字符串)
  "source": "system"          // String - 来源
}
```

### 2. TaskVo (任务视图对象)

```json
{
  "id": 1,
  "name": "任务名称",
  "description": "任务描述",
  "config": "{}",
  "source": "system",
  "status": 1,                // String - 状态(created:创建 running:运行 running[error]:不健康状态运行 error:错误 stopped:停止)
  "createTime": "2024-01-01 12:00:00",
  "updateTime": "2024-01-01 12:00:00"
}
```

### 3. ResponseWrap (统一响应格式)

```json
{
  "code": 0,                // Integer - 响应码(0:成功)
  "message": "success",       // String - 响应消息
  "data": {}                  // Object - 响应数据
}
```

---

## 📊 接口总览

| 序号 | HTTP方法 | 接口路径 | 接口名称 | 功能描述 |
|:---:|:-------:|---------|---------|---------|
| 1 | POST | `/vectum/api/v1/task/add` | 创建任务 | 创建新的任务 |
| 2 | DELETE | `/vectum/api/v1/task/{id}` | 删除任务 | 根据ID删除单个任务 |
| 3 | DELETE | `/vectum/api/v1/task/batch` | 批量删除任务 | 批量删除多个任务 |
| 4 | PUT | `/vectum/api/v1/task/{id}` | 更新任务 | 根据ID更新任务信息 |
| 5 | PUT | `/vectum/api/v1/task/batch` | 批量更新任务 | 批量更新多个任务 |
| 6 | GET | `/vectum/api/v1/task/all` | 查询所有任务 | 获取所有任务列表 |
| 7 | GET | `/vectum/api/v1/task/{id}/view` | 查询任务详情 | 根据ID查询任务详细信息 |
| 8 | POST | `/vectum/api/v1/task/{id}/toggle` | 启动/停止任务 | 切换任务的运行状态 |
| 9 | GET | `/vectum/api/v1/task/{id}/log` | 获取任务日志 | 根据任务ID和日志类型获取日志内容 |

---

## 🔌 接口详情

### 1️⃣ 创建任务

**接口地址**: `POST /vectum/api/v1/task/add`

**功能描述**: 创建新的任务

**请求参数**:
- Content-Type: `application/json`
- Body: TaskDto

**请求示例**:
```bash
curl -X POST http://localhost:11002/vectum/api/v1/task/add \
  -H "Content-Type: application/json" \
  -d '{
    "name": "用户消息推送任务",
    "description": "向用户推送重要消息通知",
    "config": "{\"target\":\"user\",\"interval\":300}",
    "source": "manual"
  }'
```

**响应示例**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 1,
    "name": "用户消息推送任务",
    "description": "向用户推送重要消息通知",
    "config": "{\"target\":\"user\",\"interval\":300}",
    "source": "manual",
    "status": 0,
    "createTime": "2024-01-01 12:00:00",
    "updateTime": "2024-01-01 12:00:00"
  }
}
```

---

### 2️⃣ 删除单个任务

**接口地址**: `DELETE /vectum/api/v1/task/{id}`

**功能描述**: 根据ID删除单个任务

**路径参数**:
| 参数名 | 类型 | 必填 | 说明 |
|-------|------|-----|------|
| id | Long | 是 | 任务ID |

**请求示例**:
```bash
curl -X DELETE http://localhost:11002/vectum/api/v1/task/123
```

**响应示例**:
```json
{
  "code": 0,
  "message": "success",
  "data": "删除成功"
}
```

---

### 3️⃣ 批量删除任务

**接口地址**: `DELETE /vectum/api/v1/task/batch?ids=1,2,3`

**功能描述**: 批量删除多个任务

**查询参数**:
| 参数名 | 类型 | 必填 | 说明 |
|-------|------|-----|------|
| ids | List\<Long\> | 是 | 任务ID列表(逗号分隔) |

**请求示例**:
```bash
curl -X DELETE "http://localhost:11002/vectum/api/v1/task/batch?ids=1,2,3,4,5"
```

**响应示例**:
```json
{
  "code": 0,
  "message": "success",
  "data": "批量删除成功"
}
```

---

### 4️⃣ 更新单个任务

**接口地址**: `PUT /vectum/api/v1/task/{id}`

**功能描述**: 根据ID更新任务信息

**路径参数**:
| 参数名 | 类型 | 必填 | 说明 |
|-------|------|-----|------|
| id | Long | 是 | 任务ID |

**请求参数**:
- Content-Type: `application/json`
- Body: TaskDto

**请求示例**:
```bash
curl -X PUT http://localhost:11002/vectum/api/v1/task/123 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "更新后的任务名称",
    "description": "更新后的描述",
    "config": "{\"target\":\"user\",\"interval\":600}",
    "source": "manual"
  }'
```

**响应示例**:
```json
{
  "code": 0,
  "message": "success",
  "data": "修改成功"
}
```

**错误响应**(任务不存在):
```json
{
  "code": 404,
  "message": "任务不存在",
  "data": null
}
```

---

### 5️⃣ 批量更新任务

**接口地址**: `PUT /vectum/api/v1/task/batch?ids=1,2,3`

**功能描述**: 批量更新多个任务

**查询参数**:
| 参数名 | 类型 | 必填 | 说明 |
|-------|------|-----|------|
| ids | List\<Long\> | 是 | 任务ID列表(逗号分隔) |

**请求参数**:
- Content-Type: `application/json`
- Body: TaskDto

**请求示例**:
```bash
curl -X PUT "http://localhost:11002/vectum/api/v1/task/batch?ids=1,2,3" \
  -H "Content-Type: application/json" \
  -d '{
    "config": "{\"target\":\"all\",\"interval\":300}"
  }'
```

**响应示例**:
```json
{
  "code": 0,
  "message": "success",
  "data": "批量修改成功: 3/3"
}
```

---

### 6️⃣ 查询所有任务

**接口地址**: `GET /vectum/api/v1/task/all`

**功能描述**: 获取所有任务列表

**请求参数**: 无

**请求示例**:
```bash
curl -X GET http://localhost:11002/vectum/api/v1/task/all
```

**响应示例**:
```json
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "用户消息推送任务",
      "description": "向用户推送重要消息通知",
      "config": "{\"target\":\"user\",\"interval\":300}",
      "source": "manual",
      "status": 1,
      "createTime": "2024-01-01 12:00:00",
      "updateTime": "2024-01-01 12:00:00"
    },
    {
      "id": 2,
      "name": "系统定时任务",
      "description": "系统定时执行的任务",
      "config": "{\"interval\":60}",
      "source": "system",
      "status": 0,
      "createTime": "2024-01-02 10:00:00",
      "updateTime": "2024-01-02 10:00:00"
    }
  ]
}
```

---

### 7️⃣ 查询任务详情

**接口地址**: `GET /vectum/api/v1/task/{id}/view`

**功能描述**: 根据ID查询任务详细信息

**路径参数**:
| 参数名 | 类型 | 必填 | 说明 |
|-------|------|-----|------|
| id | Long | 是 | 任务ID |

**请求示例**:
```bash
curl -X GET http://localhost:11002/vectum/api/v1/task/123/view
```

**响应示例**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 123,
    "name": "用户消息推送任务",
    "description": "向用户推送重要消息通知",
    "config": "{\"target\":\"user\",\"interval\":300}",
    "source": "manual",
    "status": 1,
    "createTime": "2024-01-01 12:00:00",
    "updateTime": "2024-01-01 12:00:00"
  }
}
```

**错误响应**(任务不存在):
```json
{
  "code": 404,
  "message": "任务不存在",
  "data": null
}
```

---

### 8️⃣ 启动/停止任务

**接口地址**: `POST /vectum/api/v1/task/{id}/toggle`

**功能描述**: 切换任务的运行状态
- 如果任务当前是停止状态，则启动任务
- 如果任务当前是运行状态，则停止任务

**路径参数**:
| 参数名 | 类型 | 必填 | 说明 |
|-------|------|-----|------|
| id | Long | 是 | 任务ID |

**请求示例**:
```bash
curl -X POST http://localhost:11002/vectum/api/v1/task/123/toggle
```

**响应示例**:
```json
{
  "code": 0,
  "message": "success",
  "data": null
}
```

**错误响应**(操作失败):
```json
{
  "code": 500,
  "message": "任务操作失败",
  "data": null
}
```

---

### 9️⃣ 获取任务日志

**接口地址**: `GET /vectum/api/v1/task/{id}/log?log_type=console`

**功能描述**: 根据任务ID和日志类型获取日志内容

**路径参数**:
| 参数名 | 类型 | 必填 | 说明 |
|-------|------|-----|------|
| id | Long | 是 | 任务ID |

**查询参数**:
| 参数名 | 类型 | 必填 | 说明 |
|-------|------|-----|------|
| log_type | String | 是 | 日志类型(console/system) |

**请求示例**:
```bash
curl -X GET "http://localhost:11002/vectum/api/v1/task/123/log?log_type=console"
```

**响应示例**:
```json
"2024-01-01 12:00:00 [INFO] 任务开始执行\n2024-01-01 12:00:01 [INFO] 任务执行完成"
```

**错误响应**(获取日志失败):
```json
{
  "code": 500,
  "message": "内部错误",
  "data": null
}
```

---

## 📊 响应码说明

| 响应码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 404 | 任务不存在 |
| 500 | 服务器内部错误/任务操作失败 |

---

## 🔐 注意事项

1. **认证授权**: 所有接口都需要有效的身份认证token
2. **权限控制**: 不同角色可能具有不同的操作权限
3. **数据校验**: 
   - 任务名称不能为空
   - 配置字段应为合法的JSON格式
4. **批量操作**: 
   - 批量删除/更新时，ID列表不能为空
   - 建议单次批量操作不超过100条记录
5. **日志查询**: 日志类型参数值仅支持 `console` 和 `system`
6. **任务启停**: toggle操作会立即生效，请谨慎操作

---

## 💡 使用示例

### JavaScript (Axios)

```javascript
// 创建任务
axios.post('/vectum/api/v1/task/add', {
  name: '测试任务',
  description: '这是一个测试任务',
  config: '{"interval": 300}',
  source: 'test'
})

// 获取所有任务
axios.get('/vectum/api/v1/task/all')

// 更新任务
axios.put('/vectum/api/v1/task/123', {
  name: '更新任务',
  description: '更新描述'
})

// 启动/停止任务
axios.post('/vectum/api/v1/task/123/toggle')

// 获取日志
axios.get('/vectum/api/v1/task/123/log', {
  params: {
    log_type: 'console'
  }
})

// 批量删除任务
axios.delete('/vectum/api/v1/task/batch', {
  params: {
    ids: [1, 2, 3]
  }
})
```

### cURL

```bash
# 创建任务
curl -X POST http://localhost:11002/vectum/api/v1/task/add \
  -H "Content-Type: application/json" \
  -d '{"name":"测试任务","description":"测试","config":"{}","source":"test"}'

# 获取所有任务
curl -X GET http://localhost:11002/vectum/api/v1/task/all

# 更新任务
curl -X PUT http://localhost:11002/vectum/api/v1/task/123 \
  -H "Content-Type: application/json" \
  -d '{"name":"更新任务"}'

# 启动/停止任务
curl -X POST http://localhost:11002/vectum/api/v1/task/123/toggle

# 获取日志
curl -X GET "http://localhost:11002/vectum/api/v1/task/123/log?log_type=console"

# 批量删除任务
curl -X DELETE "http://localhost:11002/vectum/api/v1/task/batch?ids=1,2,3"
```

---

## 📝 版本历史

| 版本 | 日期 | 说明 | 作者 |
|------|------|------|------|
| v1.0 | 2024-01-01 | 初始版本，包含9个核心接口 | hunter |

---

**文档生成时间**: 2026-05-20  
**最后更新时间**: 2026-05-20
