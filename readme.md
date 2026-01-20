# 项目构建与运行指南

## 后端（vehicle-sale-manager-end）

- 依赖：JDK 1.8、MySQL、Maven（已安装在 `D:\apache-maven-3.9.12\bin`）。
- 构建：在仓库根目录执行`D:\apache-maven-3.9.12\bin\mvn clean package -DskipTests`
- 开发直跑：在 `vehicle-sale-manager-end` 目录执行`D:\apache-maven-3.9.12\bin\mvn spring-boot:run`
- 运行：构建后进入 `vehicle-sale-manager-end\target`，运行`java -jar vehicle-sale-manager-end-0.0.1-SNAPSHOT.jar`
- 配置：`src\main\resources\application.yml` 中可修改数据库、端口等。

D:\apache-maven-3.9.12\bin\mvn spring-boot:run

## 前端（vehicle-sale-manager-front，Vue2 + webpack3）

- 依赖：Node.js（建议 14 或以下以兼容 webpack3 工程），npm。
- 安装依赖：在 `vehicle-sale-manager-front` 目录执行 `npm install`
- 开发启动：`npm run dev`（默认本地开发服务器）
- 生产构建：`npm run build` 输出到 `dist/`
