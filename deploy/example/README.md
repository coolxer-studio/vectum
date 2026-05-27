# Vectum 案例说明

本文档描述基于Vectum实现的数据管道传输案例，实现从SFTP中获取数据到Kafka，再从Kafka中消费数据到ClickHouse的批量数据传输。

## 环境要求

- Docker 20.10+
- Docker Compose 2.0+
- 最低配置：2核4G内存

## 快速启动

```bash
cd vectum/deploy/example
docker-compose up -d
```

## 快速验证

生成file.txt文件内容上传ftp文件
```bash
echo "张三|28|清华大学|信息工程专业\n李四|29|清华大学|信息工程专业\n王五|30|清华大学|信息工程专业" > file.txt

sftp -o StrictHostKeyChecking=no -P 2222 vectum@localhost
# 密码: vectum123

sftp> cd upload
sftp> put /path/to/local/file.txt
```

添加任务配置文件（vectot语法格式）
```bash
[sources.sftp_files]
type = "file"
include = ["/test/**"]
read_from = "end"
file_key = "file"
line_delimiter = "\n"
ignore_older = 86400

[transforms.parse_csv]
type = "remap"
inputs = ["sftp_files"]
drop_on_error = false
source = '''

  parts = split!(.message, "|")
  if length(parts) < 4 {
    return null
  }

.name = parts[0]
.school = parts[2]
.major = parts[3]
.age = parts[1]
'''

[transforms.filter_valid]
type = "filter"
inputs = ["parse_csv"]
condition = "exists(.name)"

[sinks.console_test]
type = "console"
inputs = [ "sftp_files" ]

[sinks.kafka_output]
type = "kafka"
inputs = ["filter_valid"]
bootstrap_servers = "kafka:9092"
topic = "vectum-logs"
compression = "lz4"

[sinks.console_test.encoding]
codec = "json"

[sinks.kafka_output.encoding]
codec = "json"

```
将kafka中的数据写入clickhouse中
```bash
# 输入源配置
[sources.source_kafka_msg]
type = "kafka"
bootstrap_servers = "kafka:9092"
auto_offset_reset = "earliest"
group_id = "kafka_source"
topics = [ "vectum-logs" ]

[transforms.parse_json]
  inputs        = ["source_kafka_msg"]
  type          = "remap"
  drop_on_error = false
  source        = '''
      . = parse_json!(string!(.message))
  '''

# 定义 route区分异常数据
[transforms.route]
type = "route"
inputs = ["parse_json"]
route."non_empty_or_blank" = 'exists(.name) && .age >0' # 判断字段不为空且不为空字符串

# 输出目标配置
[sinks.my_clickhouse_sink]
type = "clickhouse"
inputs = ["route.non_empty_or_blank"]
endpoint = "http://clickhouse:8123"
database = "default"
table = "vectum_logs"
auth.strategy = "basic"
auth.user = "default"
auth.password = "vectum123"
skip_unknown_fields = true

# 输出数据到日志
[sinks.console]
inputs = ["route._unmatched"]
type = "console"
encoding.codec = "json"
```



## 服务列表

| 服务 | 镜像 | 端口 | 说明 |
|------|------|------|------|
| vectum | coolxer-studio/vectum:latest | 11002 | Vectum 主应用 |
| sftp | coolxer-studio/atmoz-sftp:latest | 2222 | SFTP 文件传输服务 |
| zookeeper | coolxer-studio/bitnami-zookeeper:3.8 | 2181 | ZooKeeper 协调服务 |
| kafka | coolxer-studio/bitnami-kafka:3.2.0 | 9092 | Kafka 消息队列 |
| clickhouse | coolxer-studio/clickhouse:22.8.16 | 8123/9000/9009 | ClickHouse 数据库 |

## 服务详情

### Vectum 主应用

主服务端口 11002，提供 RESTful API 和 Web UI 界面。

- **端口**: 11002
- **依赖**: Kafka、ClickHouse、SFTP
- **工作空间**: `./workspace` 挂载到容器内 `/workspace`
- **健康检查**: `curl http://localhost:11002/actuator/health`

### SFTP 服务

用于 Vectum 任务配置文件的传输和管理。

- **端口**: 2222
- **认证用户**: `vectum / vectum123`
- **上传目录**: `/home/vectum/upload`
- **健康检查**: SFTP 连接测试

### ZooKeeper 服务

Kafka 集群协调服务。

- **端口**: 2181
- **健康检查**: `zkServer.sh status`

### Kafka 服务

分布式消息队列，用于 Vectum 任务间消息传递。

- **端口**: 9092
- **依赖**: ZooKeeper
- **消息最大字节**: 1MB
- **健康检查**: `kafka-topics.sh --list`

### ClickHouse 服务

列式数据库，用于 Vectum 日志存储和分析。

- **端口**:
  - 8123: HTTP 接口
  - 9000: Native TCP
  - 9009: 副本连接
- **认证**: `default / vectum123`
- **健康检查**: `clickhouse-client --query "SELECT 1"`

## 数据持久化

| 卷名 | 用途 | 驱动 |
|------|------|------|
| sftp-data | SFTP 用户数据 | local |
| zookeeper-data | ZooKeeper 数据目录 | local |
| kafka-data | Kafka 数据目录 | local |
| clickhouse-data | ClickHouse 数据目录 | local |
| clickhouse-logs | ClickHouse 日志 | local |

## 网络配置

- **网络名称**: vectum-network
- **驱动**: bridge

## 环境变量

| 服务 | 变量 | 值 |
|------|------|-----|
| 全局 | TZ | Asia/Shanghai |
| SFTP | SFTP_USERS | vectum:vectum123:1001 |
| ClickHouse | CLICKHOUSE_DB | default |
| ClickHouse | CLICKHOUSE_USER | default |
| ClickHouse | CLICKHOUSE_PASSWORD | vectum123 |
| Kafka | KAFKA_BROKER_ID | 1 |
| Kafka | KAFKA_CFG_LISTENERS | PLAINTEXT://:9092 |
| Kafka | KAFKA_CFG_ADVERTISED_LISTENERS | PLAINTEXT://kafka:9092 |
| Kafka | KAFKA_CFG_ZOOKEEPER_CONNECT | zookeeper:2181 |

## 访问地址

| 服务 | 地址 |
|------|------|
| Vectum Web UI | http://localhost:11002 |
| Vectum API | http://localhost:11002/vectum/api/v1 |
| Swagger 文档 | http://localhost:11002/swagger-ui/index.html |
| SFTP | sftp://localhost:2222 |
| ClickHouse HTTP | http://localhost:8123 |
| Kafka | localhost:9092 |

## 停止服务

```bash
docker-compose down
```

## 清理数据

```bash
docker-compose down -v
```

## 健康检查

所有服务均配置了健康检查机制，Vectum 依赖服务启动完成后才启动：

- `depends_on` + `condition: service_healthy` 确保依赖服务健康
- 启动间隔 `start_period: 60s` 给予足够初始化时间
