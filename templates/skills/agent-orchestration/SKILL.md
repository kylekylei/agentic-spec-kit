---
name: agent-orchestration
description: Multi-agent performance engineering, optimization, and improvement workflows. Covers agent performance analysis, prompt engineering, A/B testing, and coordinated multi-agent systems. Use when optimizing agent performance, improving prompts, or designing multi-agent coordination.
---

# Agent Orchestration

Systematic improvement and coordination of AI agents through performance analysis, prompt engineering, and multi-agent optimization.

## Part 1: Agent Performance Optimization

### Phase 1: Performance Analysis

1. **Gather Performance Data** — Task completion rate, response accuracy, tool usage efficiency, token consumption, user satisfaction indicators
2. **User Feedback Patterns** — Correction patterns, clarification requests, task abandonment points, follow-up indicators
3. **Failure Mode Classification** — Instruction misunderstanding, output format errors, context loss, tool misuse, constraint violations, edge cases
4. **Baseline Report** — Task Success Rate, Average Corrections, Tool Call Efficiency, User Satisfaction Score

### Phase 2: Prompt Engineering

1. **Chain-of-Thought Enhancement** — Explicit reasoning steps, self-verification checkpoints, recursive decomposition
2. **Few-Shot Example Optimization** — Diverse examples covering common and edge cases, positive and negative examples with annotations
3. **Role Definition Refinement** — Core purpose, expertise domains, behavioral traits, tool proficiency, constraints, success criteria
4. **Constitutional AI Integration** — Self-correction mechanisms with critique-and-revise loops
5. **Output Format Tuning** — Structured templates, dynamic formatting, progressive disclosure

### Phase 3: Testing and Validation

1. **Test Suite** — Golden path, previously failed tasks, edge cases, stress tests, adversarial inputs, cross-domain tasks
2. **A/B Testing** — Compare original vs improved agent with 100+ tasks, 95% confidence level
3. **Evaluation Metrics** — Task-level (completion, correctness, efficiency), Quality (hallucination rate, consistency, safety), Performance (latency, tokens, cost)

### Phase 4: Version Control and Deployment

1. **Versioning** — `agent-name-v[MAJOR].[MINOR].[PATCH]` with git-based storage and changelog
2. **Staged Rollout** — Alpha (5%) → Beta (20%) → Canary (20-50-100%) → Full → 7-day monitoring
3. **Rollback Triggers** — Success rate drop >10%, critical errors increase >5%, cost increase >20%

## Part 2: Multi-Agent Coordination

### Performance Profiling

- Database Performance Agent — query execution, index utilization, resource consumption
- Application Performance Agent — CPU/memory profiling, algorithmic complexity, concurrency
- Frontend Performance Agent — rendering, network requests, Core Web Vitals

### Coordination Principles

- Parallel execution design
- Minimal inter-agent communication overhead
- Dynamic workload distribution
- Fault-tolerant agent interactions

### Cost Optimization

- Token usage tracking and budget management
- Adaptive model selection based on task complexity
- Caching and result reuse
- Efficient prompt engineering

### Latency Reduction

- Predictive caching
- Pre-warming agent contexts
- Intelligent result memoization
- Reduced round-trip communication

## Continuous Improvement Cycle

- **Weekly**: Monitor metrics and collect feedback
- **Monthly**: Analyze patterns and plan improvements
- **Quarterly**: Major version updates with new capabilities
- **Annually**: Strategic review and architecture updates
