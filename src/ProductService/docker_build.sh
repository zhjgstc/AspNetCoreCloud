#!/usr/bin/env bash
# 临时构建脚本：M5 阶段会替换为标准多阶段 Dockerfile（build -> publish -> runtime）
set -euo pipefail

dotnet publish -c Release -r linux-x64
docker build -t aspnetcore_product_service .
