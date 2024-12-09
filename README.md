1. What is LangChain
2. What is LangGraph
   1. Nodes
   2. Edges
   3. State
   4. Steps and Super steps
3. Agents

   1. What is an agent: an agent is a system that uses an LLM to decide the control flow
   2. Types of agents
      ![Agent Types](https://langchain-ai.github.io/langgraph/concepts/img/agent_types.png)
   3. Structured Output
      ![Tools](https://langchain-ai.github.io/langgraph/concepts/img/tool_call.png)

   4. Agents Architectxures
      ![](https://langchain-ai.github.io/langgraph/concepts/img/multi_agent/architectures.png)

4. Memory/Persistence
   - Checkpoints: at each super step it is saved a snapshot of the graph state and represented as StateSnapshot
     ![Replay](https://langchain-ai.github.io/langgraph/concepts/img/persistence/re_play.jpg)
   - Memory Store
     ![Update](https://langchain-ai.github.io/langgraph/concepts/img/persistence/shared_state.png)
   -
5. Human in the loop
   1. Interaction Patterns:
      - approval,
        ![](https://langchain-ai.github.io/langgraph/concepts/img/human_in_the_loop/approval.png)
      - editing
        ![](https://langchain-ai.github.io/langgraph/concepts/img/human_in_the_loop/edit_graph_state.png)
      - input
        ![](https://langchain-ai.github.io/langgraph/concepts/img/human_in_the_loop/wait_for_input.png)
   1. reviewing tool calls, time travel
   1. How?
      - Breakpoints
        ```python
        # Compile our graph with a checkpoitner and a breakpoint before "step_for_human_in_the_loop"
        graph = builder.compile(checkpointer=checkpoitner, interrupt_before=["step_for_human_in_the_loop"])

        # Run the graph up to the breakpoint
        thread_config = {"configurable": {"thread_id": "1"}}
        for event in graph.stream(inputs, thread_config, stream_mode="values"):
        		    print(event)

        # Perform some action that requires human in the loop

        # Continue the graph execution from the current checkpoint
        for event in graph.stream(None, thread_config, stream_mode="values"):
        	print(event)
        ```
      - Dynamic BreakPoints this can be managed using NodeInterrupt expeptions
        ```python
        def my_node(state: State) -> State:
            if len(state['input']) > 5:
                raise NodeInterrupt(f"Received input that is longer than 5 characters: {state['input']}")
            return state

        # Attempt to continue the graph execution with no change to state after we hit the dynamic breakpoint
        for event in graph.stream(None, thread_config, stream_mode="values"):
            print(event)

        # In this case, before restarting the execution, we need to update the state, otherwise the conditional interruption
        # would be triggered again
        # Update the state to pass the dynamic breakpoint
        graph.update_state(config=thread_config, values={"input": "foo"})
        for event in graph.stream(None, thread_config, stream_mode="values"):
            print(event)
        ```
        Alternatively, if we want to skip the check but keeping the same input, we can proceed as follows:
        ```python
        # This update will skip the node `my_node` altogether
        graph.update_state(config=thread_config, values=None, as_node="my_node")
        for event in graph.stream(None, thread_config, stream_mode="values"):
            print(event)
        ```
        Here the idea is to update the state simulating the pass through the node defined by the `as_node` param, whose return value is defined by `values`. This is useful also if we are waiting for a specific human input
6. How to debug?
7. LangSmith/LangFuse

## Getting Started

```bash
  git clone https://github.com/cris96spa/llm_agents.git
  cd llm_agents
  # If make is installed
  make dev-sync
  # If make is not installed
  uv sync --cache-dir .uv_cache --all-extras --no-group build
```
