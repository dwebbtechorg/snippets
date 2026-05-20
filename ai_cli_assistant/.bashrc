# Azure AI settings
export AZURE_OPENAI_API_KEY="<APIKEY>"
export AZURE_OPENAI_ENDPOINT="<ENDPOINT>"
export DEPLOYMENT_NAME="<DEPLOYMENT_NAME>"
export AZURE_OPENAI_API_VERSION="2025-01-01-preview"

# AI helper function
askai () {
  prompt="$*"

  if [ -t 0 ]; then
    input=""
  else
    input="$(cat | head -c 12000)"
  fi

  payload=$(jq -n --arg p "$prompt" --arg i "$input" '{
    messages: [
      {
        role: "system",
        content: "You are replying in a CLI terminal so you must reply with short answers."
      },
      {
        role: "user",
        content: ($p + "\n\n" + $i)
      }
    ],
    max_completion_tokens: 800
  }')

  curl -s \
    "$AZURE_OPENAI_ENDPOINT/openai/deployments/$DEPLOYMENT_NAME/chat/completions?api-version=$AZURE_OPENAI_API_VERSION" \
    -H "Content-Type: application/json" \
    -H "api-key: $AZURE_OPENAI_API_KEY" \
    -d "$payload" \
  | jq -r '.choices[0].message.content'
}
