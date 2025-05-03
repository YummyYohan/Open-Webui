# Open WebUI - Development Setup & ngrok Exposure Instructions

This guide explains how to set up the Open WebUI development environment locally and how to temporarily expose it to the internet using ngrok for testing or collaboration.

## 1. Prerequisites

Before you begin, ensure you have the following software installed and configured:

*   **Git:** For cloning the repository. ([https://git-scm.com/downloads](https://git-scm.com/downloads))
*   **Conda (Miniconda recommended):** For managing Python environments (if needed by backend setup). Ensure it's added to your system PATH. ([https://docs.conda.io/projects/miniconda/en/latest/](https://docs.conda.io/projects/miniconda/en/latest/))
*   **Node.js & npm:** For running the frontend. LTS version recommended. ([https://nodejs.org/](https://nodejs.org/))
*   **Ollama:** The LLM runner. Download and install it. You will need to run it separately (e.g., `ollama serve` or via the desktop app) for the WebUI backend to connect to it. ([https://ollama.com/](https://ollama.com/))
*   **ngrok:** For exposing your local server. Download, sign up for a free account, and authenticate your client by running `ngrok config add-authtoken YOUR_AUTH_TOKEN` (replace `YOUR_AUTH_TOKEN` with your actual token from the ngrok dashboard). ([https://ngrok.com/download](https://ngrok.com/download))
*   **jq:** Command-line JSON processor used by the ngrok script. (Install via package manager, e.g., `brew install jq`, `apt-get install jq`, `yum install jq`)
*   **curl:** Command-line tool for transferring data with URLs. (Usually pre-installed on Linux/macOS).

**Check Prerequisites Automatically:**

You can run the following script to verify if the required command-line tools are detected:

```bash
sh scripts/check_prereqs.sh
```

If any checks fail, please install the missing software manually using the links above.

## 2. Initial Setup

1.  **Clone the Repository:**
    ```bash
    git clone <repository_url> # Replace with the actual URL
    cd Open-Webui # Or your repository directory name
    ```
2.  **Run the Setup Script:** This script will check prerequisites again and install frontend dependencies.
    ```bash
    sh scripts/setup.sh
    ```

## 3. Running Locally (Development Mode)

To run the application on your local machine:

1.  **Start Ollama:** Ensure the Ollama service/application is running.
2.  **Start the Backend:**
    *   Open a terminal window.
    *   Navigate to the backend directory: `cd backend`
    *   Run the development script: `sh dev.sh`
    *   Keep this terminal open. It typically runs on port 8080.
3.  **Start the Frontend:**
    *   Open a *second* terminal window.
    *   Navigate to the project root directory (`Open-Webui`).
    *   Run the development script: `npm run dev`
    *   Keep this terminal open. It typically runs on port 5173.
4.  **Access:** Open your web browser and navigate to `http://localhost:5173` (or the specific port shown in the `npm run dev` output).

## 4. Exposing Locally with ngrok

To temporarily share your running local instance with someone over the internet:

1.  **Ensure Local Instance is Running:** Make sure both the backend (`sh backend/dev.sh`) and frontend (`npm run dev`) are running in their respective terminals as described in Step 3.
2.  **Run the Exposure Script:**
    *   Open a *third* terminal window.
    *   Navigate to the project root directory (`Open-Webui`).
    *   Run the script:
        ```bash
        sh scripts/expose_with_ngrok.sh
        ```
        *   (Optional: You can specify a different frontend port as an argument, e.g., `sh scripts/expose_with_ngrok.sh 3000` if your frontend runs on port 3000).
3.  **Wait & Check Output:** The script will:
    *   Start `ngrok` in the background.
    *   Attempt to retrieve the public `https://` URL.
    *   Attempt to add the ngrok hostname to `vite.config.ts`'s `allowedHosts`.
    *   **IMPORTANT:** If the script successfully adds the host, it will prompt you to **manually restart the frontend development server** (`npm run dev`). Stop it (`Ctrl+C`) and restart it (`npm run dev`) in its terminal window.
    *   If the script *fails* to add the host automatically, it will provide instructions to add it manually to `vite.config.ts` before restarting the frontend.
4.  **Share the URL:** Once the frontend is restarted (if necessary), copy the `https://...ngrok-free.app` URL displayed by the script and share it.
5.  **Keep Running:** The backend, frontend, and the background `ngrok` process must remain running for the URL to work.
6.  **Stopping Exposure:**
    *   To stop sharing, run the stop script in the project root:
        ```bash
        sh scripts/stop_ngrok.sh
        ```
    *   You can then stop the frontend and backend terminals (`Ctrl+C`).

## Notes

*   The automatic modification of `vite.config.ts` by the `expose_with_ngrok.sh` script might fail on some systems or configurations. Follow the manual instructions provided by the script if this happens.
*   `ngrok` free tier URLs are temporary and change each time you run the `expose_with_ngrok.sh` script.
*   This setup exposes your *development* environment. It's not optimized for production performance or security. 