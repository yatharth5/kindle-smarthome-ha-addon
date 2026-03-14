ARG BUILD_FROM
FROM $BUILD_FROM

# Install Node.js 18
RUN apk add --no-cache nodejs npm

WORKDIR /app

# Copy source files
COPY src/package.json src/package-lock.json* ./
RUN npm install --omit=dev

COPY src/ .

# WebSocket polyfill for Node.js < 22
RUN printf 'import { WebSocket } from "ws";\nglobalThis.WebSocket = WebSocket;\n' > /app/ws-polyfill.mjs

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
