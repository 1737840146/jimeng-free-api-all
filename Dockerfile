FROM node:lts AS build_image

WORKDIR /app

COPY . /app

RUN yarn install --registry https://registry.npmmirror.com/ --ignore-engines && yarn run build

FROM node:lts

# 安装 Chromium 依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libatspi2.0-0 \
    libwayland-client0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build_image /app/configs /app/configs
COPY --from=build_image /app/package.json /app/package.json
COPY --from=build_image /app/dist /app/dist
COPY --from=build_image /app/public /app/public
COPY --from=build_image /app/node_modules /app/node_modules

WORKDIR /app

# 安装 Playwright Chromium 浏览器
RUN npx playwright-core install chromium

EXPOSE 8000

CMD ["npm", "start"]
