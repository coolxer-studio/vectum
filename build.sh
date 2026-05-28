#!/bin/bash

IMAGE_NAME="vectum"
IMAGE_TAG="latest"

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