# Text Evaluator Tool

**Our Text Evaluator Tool is a web application built using [Open WebUI](https://github.com/open-webui/open-webui) with [Ollama](https://ollama.com/) for text evaluation.** 
This project aims to support writers in analyzing their work through different modes of evaluation using LLMs. For text evaluation, users simply need to input a short story, select a mode of evaluation, and select a model. By simplifying this process and incorporating a user-friendly UI, users can easily have their text evaluated with additional explanations. 

## Modes of Evaluation

### Unreliable Narrator
Evaluates the reliability of the narrator in a short story written in first-person. This is analyzed through 3 lenses: 
- **Intra-narrational**: Examines inconsistencies within the narrator’s own account (ex: contradictions, gaps in memory, confused sequencing). 
- **Inter-narrational**: Examines discrepancies between the narrator’s version of events and the perspectives of other characters or objective facts within the story. 
- **Inter-textual**: Examines how the narrator fits within or subverts established literary archetypes (ex: the trickster, antihero, or picaro)

### Show, Don't Tell
Evaluates whether the short story is predominantly showing or telling. Also, evaluates where in the short story the author is telling rather than showing.  

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

3.  **Set up Backend Python Environment:**
    The backend requires a specific Python environment. Create and activate it using Conda:
    ```bash
    # Create the environment (only needs to be done once)
    conda create -n open-webui python=3.11 -y

    # Activate the environment (needs to be done in the terminal session where you run the backend)
    conda activate open-webui
    ```

4.  **Install Backend Dependencies:**
    While the conda environment is active, install the required Python packages:
    ```bash
    # Make sure you are in the project root directory
    # Ensure 'conda activate open-webui' was run in this terminal
    pip install -r backend/requirements.txt
    ```

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
    *   **Activate the Conda Environment**: Make sure you are in the correct environment before running the backend:
        ```bash
        conda activate open-webui
        ```
    *   Run the backend development script:
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

## Manual Installation Guide

### 3. Backend Setup and Launch

First, set up a Conda environment with Python 3.11:
```bash
conda create -n open-webui python=3.11
conda activate open-webui
```

Next, navigate to the backend directory and install the required Python packages:
```bash
cd backend
pip install -r requirements.txt
```

Then, launch the backend server:
```bash
sh dev.sh
```
This will start the backend API server, usually on `http://localhost:8080`.

### 4. Frontend Setup and Launch

Navigate back to the project root directory (`Open-Webui`) and install the frontend dependencies:
```bash
cd ..
npm install
```

Now, start the frontend development server:
```bash
npm run dev
```
This will typically make the web UI available at `http://localhost:5173` (check the output of the command for the exact URL).

**Accessing the UI:** Open your web browser and navigate to the frontend URL (e.g., `http://localhost:5173`), **not** the backend URL (`http://localhost:8080`).

**Troubleshooting:**

*   **Vite Errors (`_metadata.json` not found, `Outdated Optimize Dep`, etc.):** If you encounter errors related to Vite or `node_modules/.vite` during `npm run dev` or `npm install`, or if the **frontend UI gets stuck on the loading logo**, try removing the Vite cache and reinstalling dependencies:
    ```bash
    # In the Open-Webui root directory
    rm -rf node_modules/.vite
    rm -rf node_modules
    npm install
    npm run dev
    ```
*   **`{"detail":"Not Found"}` Error:** This usually means you are trying to access the backend URL (e.g., `http://localhost:8080`) directly in your browser. Make sure you are accessing the frontend URL provided by the `npm run dev` command (e.g., `http://localhost:5173`).

*   **Prompt Sent, No Response:** If the UI loads but sending a prompt results in no response (the loading indicator spins indefinitely):
    1.  **Check Backend Logs:** Look at the terminal running `sh dev.sh`. Are there errors after the initial `POST /api/v1/chats/...` log?
    2.  **Check Ollama Logs:** Ensure `ollama serve` is running (preferably started manually in a dedicated terminal so you can see logs). Check its output for errors or activity when you send the prompt.
    3.  **Check Browser Network Tab:** Open browser DevTools (F12), go to Network, send the prompt, and check the status of the chat request (e.g., `POST /api/v1/chats/...`). Is it pending? Did it error out?

*   **Ollama Port Conflict (`address already in use`) or Unresponsive Ollama:** If you cannot start `ollama serve` due to the port being in use, or if the backend/Ollama logs indicate Ollama isn't responding correctly, the existing Ollama process (often started by the desktop app or a system service) might need to be stopped forcefully:
    1.  Find the process ID (PID) using the port (default 11434): `lsof -ti :11434`
    2.  Stop the process using its PID: `kill <PID>` (e.g., `kill 12345`)
    3.  If it restarts or `kill` doesn't work, use `kill -9 <PID>`.
    4.  Once stopped, run `ollama serve` manually in a dedicated terminal to monitor its logs directly. 

## Host Using ngrok
Instructions available [here](https://tarheels.live/teamn/d4-user-manual/).

## Additional Documentation

Additional documentation can be found in the [User Manual](https://tarheels.live/teamn/d4-user-manual/). 

---

Created by [Team N](https://tarheels.live/teamn/about-us/)
