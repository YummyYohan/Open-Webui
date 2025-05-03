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


## Local Set Up
1. Clone repository
2. Download [Ollama](https://ollama.com/) and follow set up instructions
3. Run frontend: 
- Create a .env file: ``` bash cp -RPp .env.example .env ```
- Install dependencies: ``` bash npm install ```
- Start the frontend server: ``` bash npm run dev ```
4. Run backend: 
- In a new terminal, navigate to the backend:  ``` bash cd backend ```
- Use Conda for environment setup:
``` bash conda create --name open-webui python=3.11```
``` bash conda init bash ``` (if using bash, use bash. If using Zsh, use zsh)
``` bash conda activate open-webui ```
- Install dependencies: ``` bash pip install -r requirements.txt -U ```
- Start the backend: ``` bash sh dev.sh ```

Ollama instance should automatically [connect](https://docs.openwebui.com/getting-started/quick-start/starting-with-ollama/). 

## Host Using ngrok


## Additional Documentation

Additional documentation can be found in the [User Manual](https://tarheels.live/teamn/d4-user-manual/). 

---

Created by [Team N](https://tarheels.live/teamn/about-us/)
