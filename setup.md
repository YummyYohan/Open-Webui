# Open WebUI - Local Development Setup

This guide explains how to install dependencies and run the Open WebUI frontend and backend locally for development purposes.

## 1. Prerequisites

Before you begin, ensure you have the following software installed and available in your system's PATH:

*   **Git:** ([https://git-scm.com/downloads](https://git-scm.com/downloads))
*   **Conda (Miniconda recommended):** ([https://docs.conda.io/projects/miniconda/en/latest/](https://docs.conda.io/projects/miniconda/en/latest/))
*   **Node.js & npm:** (LTS version recommended) ([https://nodejs.org/](https://nodejs.org/))
*   **Ollama:** ([https://ollama.com/](https://ollama.com/)) - *Must be installed and running separately.*
*   **ngrok:** ([https://ngrok.com/download](https://ngrok.com/download)) - *Required for helper scripts.*
*   **jq:** (e.g., `brew install jq`, `apt-get install jq`) - *Required for helper scripts.*
*   **curl:** (Usually pre-installed on Linux/macOS) - *Required for helper scripts.*

You can verify if the command-line tools are detected by running:
```bash
sh scripts/check_prereqs.sh
```

## 2. Installation (After Prerequisites)

1.  **Clone the Repository (if you haven't already):**
    ```bash
    git clone https://github.com/YummyYohan/Open-Webui # Replace <repository_url> with the actual URL
    cd Open-Webui # Or your repository directory name
    ```

2.  **Run the Setup Script:**
    This script primarily installs the required **frontend** Node.js dependencies.
    ```bash
    sh scripts/setup.sh
    ```
    *Note: The backend Python dependencies are typically managed and installed when you first run the backend development server (see next section).*

## 3. Running Locally

You'll need **three separate terminal windows/tabs**: one for Ollama, one for the backend, and one for the frontend.

1.  **Start Ollama:**
    Ensure the Ollama service or desktop application is running. You might start it with:
    ```bash
    ollama serve
    ```
    (Keep this running).

2.  **Start the Backend:**
    *   Navigate to the backend directory:
        ```bash
        cd backend
        ```
    *   Run the backend development script. This will often create/activate a Conda environment and install Python dependencies on the first run.
        ```bash
        sh dev.sh
        ```
    *   Keep this terminal open. The backend typically runs on port `8080`.

3.  **Start the Frontend:**
    *   Navigate back to the project **root** directory (the one containing this README):
        ```bash
        cd .. # Or `cd <project_root>` if you are not in the backend directory
        ```
    *   Run the frontend development script:
        ```bash
        npm run dev
        ```
    *   Keep this terminal open. The frontend typically runs on port `5173`.

4.  **Access the WebUI:**
    Open your web browser and navigate to `http://localhost:5173` (or the specific port shown in the `npm run dev` output). 