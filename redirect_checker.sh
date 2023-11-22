#!/bin/bash

url=$1
max_redirects=10
auth_header=""
count=1

# Check if username and password are provided as optional parameters
if [ "$#" -ge 3 ]; then
  username=$2
  password=$3
  auth_header="Authorization: Basic $(echo -n "$username:$password" | base64)"
fi

if [[ ! -z "$auth_header" && auth_header != "" ]]; then
  echo "- using Basic Auth"
else
  echo "+ not using Authorization"
fi

echo "Start URL: $url"

function get_redirect_url {
  if [[ ! -z "$auth_header" && auth_header != "" ]]; then
    result=$(curl --silent --output /dev/null --write-out "%{http_code} %{redirect_url}" "$url" -I -H "$auth_header")
    printf "%s" "$result"
  else
    result=$(curl --silent --output /dev/null --write-out "%{http_code} %{redirect_url}" "$url")
    printf "%s" "$result"
  fi
}

function get_server_header {
    if [[ ! -z "$auth_header" && auth_header != "" ]]; then
      server_header=$(curl -sI -H "$auth_header" "$url" | awk -F ': ' '/^server:/ {print $2}')
    else
        server_header=$(curl -sI "$url" | awk -F ': ' '/^server:/ {print $2}')
    fi

    echo ${server_header}
    if [[ ! -z "$server_header" && ( "$server_header" == "Apache" || "$server_header" == "nginx" ) ]]; then
      echo ${server_header}
    fi
}

  if [[ ! -z "$auth_header" && auth_header != "" ]]; then
    echo "- using Basic Auth"
  fi
# Initial request
response=$(get_redirect_url)

while true; do
  http_code=$(echo "$response" | awk '{print $1}')
  redirect_url=$(echo "$response" | awk '{print $2}')

  if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
  # if [ "$http_code" -eq 200 ]; then
    server=$(get_server_header)
    echo "Final URL: $url with HTTP Code: $http_code, Server: $server"
    break
  elif [ "$http_code" -ge 300 ] && [ "$http_code" -lt 400 ]; then
    if [ -z "$redirect_url" ]; then
      echo "Error: Missing redirect URL in response."
      exit 1
    fi

    server=$(get_server_header)
    echo "$count, Redirecting from $url to $redirect_url with HTTP Code: $http_code, Server: $server"

    url="$redirect_url"
    response=$(get_redirect_url)
    server=$(get_server_header)
    count=$((count+1))


  elif [ "$http_code" -ge 400 ]; then
    echo "Error: HTTP Code $http_code. Stopping."
    exit 1
  else
    echo "Unexpected HTTP Code: $http_code. Stopping."
    exit 1
  fi

  ((max_redirects--))
  if [ "$max_redirects" -eq 0 ]; then
    echo "Error: Maximum number of redirects reached. Stopping."
    exit 1
  fi
done
