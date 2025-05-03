"""
title: Show, Dont Tell
author: open-webui
author_url: https://github.com/open-webui
funding_url: https://github.com/open-webui
version: 0.1
"""

from pydantic import BaseModel, Field
from typing import Optional


class Filter:
    class Valves(BaseModel):
        priority: int = Field(
            default=0, description="Priority level for the filter operations."
        )
        pass

    def __init__(self):
        # Indicates custom file handling logic. This flag helps disengage default routines in favor of custom
        # implementations, informing the WebUI to defer file-related operations to designated methods within this class.
        # Alternatively, you can remove the files directly from the body in from the inlet hook
        # self.file_handler = True

        # Initialize 'valves' with specific configurations. Using 'Valves' instance helps encapsulate settings,
        # which ensures settings are managed cohesively and not confused with operational flags like 'file_handler'.
        self.valves = self.Valves()
        pass

    def inlet(self, body: dict, __user__: Optional[dict] = None) -> dict:
        system_prompt = {
            "role": "system",
            "content": """You are a literary writing expert helping users distinguish "showing" versus "telling" in narrative writing.
            
            Definitions:
            -  Creative writing teachers often describe "showing" as putting the reader into the scene and "telling" as summarizing the scene. For example, a character's emotions could be described as happy/sad/angry/joyful/etc. (telling), or the character's emotions could be inferred with a description of his/her/their facial expressions (showing)
            - "Showing" means the text uses vivid sensory details, behavior, or dialogue to convey meaning indirectly.
            - "Telling" means the text summarizes or explains meaning directly.
            
            Your job is to:
            1. Answer the question: “Does this narrative show?” → Give a interpretation of whether it is predominatly showing or telling and how it shows.
            2. Answer the question: “Where does this narrative tell?” → Return the **original excerpt** but with parts that "tell" wrapped in <mark>...</mark> tags.

            When wrapping text that tells, always include the full sentence or clause that performs the telling. Do not wrap only single words like “nervous” — instead, wrap full expressions like “The kitten was nervous.”
            Do not highlight every sentence. Only mark parts that explicitly tells.

            Format:
            <hr></hr>
            <h2> Does this narrative show?</h2> [interpretive answer]
            <hr></hr>
            <h2> Where does this narrative tell?</h2>
            [original text, with telling parts wrapped in <mark>...</mark>]
            """,
        }

        body.setdefault("messages", []).insert(0, system_prompt)
        return body

    def outlet(self, body: dict, __user__: Optional[dict] = None) -> dict:

        return body
