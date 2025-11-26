# Setup Instructions

## Prerequisites
- Docker and Docker Compose installed
- OpenAI API key (get from https://platform.openai.com/api-keys)

## Setup Steps

### 1. Configure Environment Variables

Copy the example files and add your API key:

```bash
# Copy root-level environment file
cp .env.example .env

# Copy server environment file
cp server/.env.example server/.env
```

### 2. Add Your OpenAI API Key

Edit both `.env` files and replace `your_openai_api_key_here` with your actual OpenAI API key:

**Root `.env` file:**
```bash
OPENAI_API_KEY=sk-your-actual-api-key-here
```

**`server/.env` file:**
```bash
OPENAI_API_KEY=sk-your-actual-api-key-here
```

### 3. Build and Start the Containers

```bash
# Stop any running containers
docker-compose down

# Build and start all services
docker-compose up --build
```

### 4. Access the Application

- **Frontend UI:** http://localhost:3001
- **API Endpoint:** http://localhost:3000/api/chat
- **OpenCode Server:** http://localhost:4096

### 5. View Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f opencode-server
docker-compose logs -f opencode-next-api
docker-compose logs -f front-end-ui
```

## Testing the API

Test the chat endpoint directly:

```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "hello"}'
```

Expected response format:
```json
{
  "response": {
    "output_text": "Response text in Czech",
    "products": null
  },
  "sessionId": "session-id"
}
```

## Troubleshooting

### Model Not Found Error
If you see `ProviderModelNotFoundError`, check:
1. Your OpenAI API key is correctly set in both `.env` files
2. The `OPENCODE_MODEL` is set to a valid OpenAI model (e.g., `openai/gpt-4o`)

### API Key Issues
If the server fails to start:
1. Verify your OpenAI API key is valid
2. Check the server logs: `docker-compose logs opencode-server`
3. Ensure the `.env` files are in the correct locations

### Container Issues
```bash
# Rebuild from scratch
docker-compose down
docker-compose build --no-cache
docker-compose up
```
