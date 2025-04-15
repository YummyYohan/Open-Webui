PORT="${PORT:-8080}"
uvicorn open_webui.main:app --port 8080 --host 0.0.0.0 --reload