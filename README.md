# Aperitech - LLM Agents: LangChain and LangGraph

## Overview

This repository explores the use of **LangChain** and **LangGraph** for building applications powered by large language models (LLMs). It provides an interactive notebook and code examples to demonstrate how these frameworks can be used to create modular and efficient workflows for LLM-powered applications.

## What is LangChain?

[LangChain](https://python.langchain.com) is a framework for developing applications powered by large language models. It allows developers to construct workflows as chains of modular operations that execute in sequence or parallel.

Key features of LangChain:

- **Prompt Engineering**: Simplifies crafting and managing prompts for LLMs.
- **Information Retrieval**: Integrates with various retrieval systems.
- **LLM Interaction**: Supports chatbot-like interactions.
- **Output Structuring**: Parses and formats LLM output.
- **Persistence**: Manages and stores interaction histories.
- **Tool Management**: Orchestrates external tools for LLMs.

![LangChain Stack](https://python.langchain.com/svg/langchain_stack_112024_dark.svg)

## What is LangGraph?

[LangGraph](https://github.com/langgraph/langgraph) builds upon LangChain to provide graph-based orchestration of LLM-powered workflows. By modeling workflows as directed acyclic graphs (DAGs), LangGraph enhances the modularity and flexibility of LangChain applications.

## Prerequisites

To run the code in this repository, ensure you have the following installed:

- Python 3.12+
- uv 0.5.0+ [https://docs.astral.sh/uv/getting-started/installation/](https://docs.astral.sh/uv/getting-started/installation/)
- make [Optional for easy setup] [make for windows](https://stackoverflow.com/questions/32127524/how-to-install-and-use-make-in-windows)

### Key Libraries

- **LangChain**: Workflow management for LLMs.
- **LangGraph**: Graph-based workflow orchestration.

## Getting Started

```bash
  git clone https://github.com/cris96spa/llm_agents.git
  cd llm_agents
  # If make is installed
  make dev-sync
  # If make is not installed
  uv sync --cache-dir .uv_cache --all-extras --no-group build
```
