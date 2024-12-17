# Large Language Model Agents Aperitech

## 1. What is LangChain?

LangChain provides tools and abstractions to simplify the development of applications powered by Large Language Models (LLMs).

![alt text](https://python.langchain.com/svg/langchain_stack_112024_dark.svg)

## 2. What is LangGraph?

LangGraph introduces graph-based computation, enabling flexible and structured control flow for agents. Key concepts are:

- **Nodes**: define specific computational unit or function within the graph.

- **Edges**: determine the execution flow between nodes.

- **State**: captures the intermediate and final results within the graph's execution.

- **Steps** and Super steps: represent individual and grouped execution cycles, respectively.

---

## 2. Agents

### What is an agent?

An **Agent** uses an LLM to dynamically decide its next actions and control flow based on inputs.

### Types of agents

![Agent Types](https://langchain-ai.github.io/langgraph/concepts/img/agent_types.png)

### Structured Output

Agents can call tools and produce structured output:

![Tools](https://langchain-ai.github.io/langgraph/concepts/img/tool_call.png)

```python
 from langchain.agents import Tool
 from langchain.chat_models import ChatOpenAI

 def search_tool(query: str) -> str:
     return f"Results for {query}"

 llm = ChatOpenAI()
 tools = [Tool(name="Search", func=search_tool, description="Searches the web")]

 agent = create_react_agent(llm=llm, tools=tools)
```

### Architectures

![](https://langchain-ai.github.io/langgraph/concepts/img/multi_agent/architectures.png)

---

## 3. Memory and Persistence

### Checkpoints

Save snapshots of graph states at specific steps:

![Replay](https://langchain-ai.github.io/langgraph/concepts/img/persistence/re_play.jpg)

```python
builder.compile(checkpointer=checkpointer)
```

### Memory Store

Shared states enable persistent graph operations across runs.

![Update](https://langchain-ai.github.io/langgraph/concepts/img/persistence/shared_state.png)

## 4. Human in the Loop

### Interaction Patterns

- **Approval**: Pause for approval before proceeding.

  ![](https://langchain-ai.github.io/langgraph/concepts/img/human_in_the_loop/approval.png)

- **Editing**: Allow manual changes to graph states.

  ![](https://langchain-ai.github.io/langgraph/concepts/img/human_in_the_loop/edit_graph_state.png)

- **Input**: Wait for explicit user input during execution.

  ![](https://langchain-ai.github.io/langgraph/concepts/img/human_in_the_loop/wait_for_input.png)

### Breakpoints

Breakpoints enable stopping and resuming execution with human intervention.

```python
# Define Breakpoint and State Interrupts
from langgraph.checkpoints import NodeInterrupt

def my_node(state: State) -> State:
    if len(state['input']) > 5:
        raise NodeInterrupt("Input too long")
    return state

# Update state to bypass interruption
builder.compile().update_state(config=config, values={"input": "short input"})
```

---

## 5. Debugging

Debugging graphs involves tracing execution and inspecting state transitions.

---

### LangSmith/LangFuse

Integrate tools like **LangSmith** and **LangFuse** for monitoring and logging graph-based LLM applications.

---

## Getting Started

Clone the repository and set up the environment:

```bash
  git clone https://github.com/cris96spa/llm_agents.git
  cd llm_agents
  # If make is installed
  make dev-sync
  # If make is not installed
  uv sync --cache-dir .uv_cache --all-extras --no-group build
```
