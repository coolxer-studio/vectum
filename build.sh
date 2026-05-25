#!/bin/bash

# Docker Hub 配置
DOCKER_HUB_USERNAME="your_username"
IMAGE_NAME="vectum"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "========== 开始构建项目 =========="

echo "1. 执行 Maven 打包..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    echo "Maven 打包失败!"
    exit 1
fi

echo "2. Maven 打包成功!"

echo "3. 构建 Docker 镜像..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

if [ $? -ne 0 ]; then
    echo "Docker 构建失败!"
    exit 1
fi

echo "4. Docker 镜像构建成功!"
echo "镜像名称: ${IMAGE_NAME}:${IMAGE_TAG}"

echo "5. 为镜像添加 Docker Hub 标签..."
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_NAME}

if [ $? -ne 0 ]; then
    echo "添加标签失败!"
    exit 1
fi

echo "6. 登录 Docker Hub..."
docker login

if [ $? -ne 0 ]; then
    echo "Docker Hub 登录失败!"
    exit 1
fi

echo "7. 推送镜像到 Docker Hub..."
docker push ${FULL_IMAGE_NAME}

if [ $? -ne 0 ]; then
    echo "推送镜像失败!"
    exit 1
fi

echo "8. 推送成功!"
echo "镜像已推送到: ${FULL_IMAGE_NAME}"

echo "9. 登出 Docker Hub..."
docker logout

echo "========== 构建完成 =========="
