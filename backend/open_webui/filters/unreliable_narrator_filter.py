"""
title: Unreliable Narrator Test
author: open-webui
author_url: https://github.com/open-webui
funding_url: https://github.com/open-webui
version: 0.1
"""

from pydantic import BaseModel, Field
from typing import Optional
import re


# Helper functions
def replace_tag(match):
    tag = match.group(1)
    content = match.group(2)
    tag_styles = {
        "INTRA": ("Intra-Narrational", "rgb(255, 193, 7)", "black", "intra"),
        "INTER": ("Inter-Narrational", "rgb(3, 169, 244)", "black", "inter"),
        "TEXTUAL": ("Inter-Textual", "rgb(244, 67, 54)", "white", "textual"),
    }
    tooltip, bg_color, text_color, id_ = tag_styles[tag]
    return f'<mark data-tooltip="{tooltip}" style="background-color: {bg_color}; cursor: pointer; color: {text_color};" id="{id_}">{content}</mark>'


def replace_explanation(match):
    tag = match.group(1)
    content = match.group(2).strip()
    headings = {
        "INTRA": "Intra-narrational",
        "INTER": "Inter-narrational",
        "TEXTUAL": "Inter-Textual",
    }
    class_map = {"INTRA": "intra", "INTER": "inter", "TEXTUAL": "textual"}
    id_ = class_map[tag]
    heading = headings[tag]
    return (
        f'<span class="explanation {id_}" id="explanation-{id_}" style="display: none;">'
        f"<h3>{heading}</h3>{content}</span>"
    )


# Filter
class Filter:
    class Valves(BaseModel):
        priority: int = Field(
            default=0, description="Priority level for the filter operations."
        )
        pass

    def __init__(self):
        self.valves = self.Valves()

    def inlet(self, body: dict, __user__: Optional[dict] = None) -> dict:

        if body.get("stream", True):
            body["stream"] = False

        # System prompt setup with literary analysis instructions
        system_prompt = {
            "role": "system",
            "content": """
            You are a literary analysis assistant. A user will paste in a short narrative story. Your job is to analyze the narrator's reliability from three literary angles:
            
            1. **Intra-narrational Unreliability** – Contradictions, confusion, selective memory.
            2. **Inter-narrational Unreliability** – Conflicts between narrator and other characters/facts.
            3. **Inter-textual Unreliability** – Known archetypes (e.g., trickster, antihero, picaro).
            
            Format your response like this:
            
            1. Return the original story with phrases wrapped using simplified markup:
                - [INTRA]highlighted phrase[/INTRA]
                - [INTER]highlighted phrase[/INTER]
                - [TEXTUAL]highlighted phrase[/TEXTUAL]
            
            2. Provide one explanation per category like this:
                - [EXPLAIN-INTRA] Your explanation here. [/EXPLAIN-INTRA]
                - [EXPLAIN-INTER] Your explanation here. [/EXPLAIN-INTER]
                - [EXPLAIN-TEXTUAL] Your explanation here. [/EXPLAIN-TEXTUAL]
            
            **Important:**
            - Use raw brackets exactly as shown.
            - Only wrap each phrase once.
            - Do not use bullet points
            - Do not summarize or rewrite the story.
            """,
        }

        body.setdefault("messages", []).insert(0, system_prompt)
        return body

    def postprocess(self, output: str) -> str:
        print("POSTPROCESS CALLED")

        # Convert highlight tags (INTRA, INTER, TEXTUAL)
        output = re.sub(
            r"\[(INTRA|INTER|TEXTUAL)\](.*?)\[/\1\]",
            replace_tag,
            output,
            flags=re.DOTALL,
        )

        # Convert explanation blocks (EXPLAIN-INTRA, EXPLAIN-INTER, EXPLAIN-TEXTUAL)
        output = re.sub(
            r"\s*\[EXPLAIN-(INTRA|INTER|TEXTUAL)\](.*?)\[/EXPLAIN-\1\]\s*",
            replace_explanation,
            output,
            flags=re.DOTALL,
        )

        return output

    def outlet(self, body: dict, __user__: Optional[dict] = None) -> dict:
        print("Running outlet...")

        # Check if "choices" exists and is not empty
        if body.get("messages"):
            print("messages found:", body["messages"])
            for message in body["messages"]:
                if message["role"] == "assistant":
                    print("Processing message:", message)
                    print("Original content:", message["content"])

                    # Apply postprocess function
                    new_content = self.postprocess(message["content"])
                    print("Updated content:", new_content)

                    message["content"] = new_content
        else:
            print("No messages found in the body.")

        print("End of outlet...")
        return body
