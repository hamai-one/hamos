# LISA SYSTEM — QUICK REFERENCE & TECHNICAL GLOSSARY

## Agent Capabilities Quick Matrix

```
Agent ID | Name              | Primary Domain           | Tier   | Tools              | Prohibitions
---------|-------------------|--------------------------|--------|--------------------|--------------------------
agent1   | The Weaver        | UI/UX/Frontend/Design    | Flash  | filesystem         | backend-logic, database
agent2   | The Logic Gate    | Backend/State/API/Logic  | Flash  | fs, ast            | ui-styling, css
agent3   | The Sentinel      | Security/Auth/Encryption | Pro    | fs, ast            | ui-design, prototyping
agent4   | The Accelerator   | Performance/Memory/Cache | Pro    | fs, ast            | security-audits, ui
agent5   | The Archivist     | Storage/DB/Persistence  | Flash  | fs, database       | web-navigation
agent6   | The Inquisitor    | QA/Testing/Edge Cases    | Pro    | fs, ast, shell     | ui-design
agent7   | The Mechanic      | DevOps/Build/Deploy      | Flash  | fs, shell          | security-audit, ui
agent8   | The Chronicler    | Docs/Cleanup/Refactor    | Flash  | fs                 | backend-ops, security
```

## Model Fallback Chain

```
Tier 1. Gemini Pro 3.1       (Most Capable)
  ↓ [if failure + key rotation]
Tier 2. Gemini Flash 3
  ↓
Tier 3. Gemini Flash 1.5
  ↓
Tier 4. Gemini Flash 2.0
  ↓
Tier 5. Gemini Pro 2.0
  ↓
Tier 6. Gemini Pro 1.5
  ↓
Tier 7. Gemini Flash Lite 3.1
  ↓
Tier 8. Gemini Flash 2.5
  ↓
Tier 9. Gemini Pro 2.5       (Fallback)
```

## Core Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  HTML Input / User Request                                  │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────────┐
│  LisaOrchestrator                                           │
│  - Initialize capabilities                                  │
│  - Route request → Sovereign                                │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────────┐
│  Sovereign Core                                             │
│  1. IntentClassifier → analyze complexity/domain            │
│  2. ContextWeaver → inject relevant memory                  │
│  3. Route Decision → tier (Flash/Pro/Deep) + persona        │
└──────────────┬──────────────────────────────────────────────┘
               │
         ┌─────┼─────┐
         ▼     ▼     ▼
      Flash  Pro   Deep
       Tier  Tier  Tier
         │     │     │
         ▼     ▼     ▼
    Kernel  Mind   DeepResearch
    Direct  Plan   Multi-Step
    Call    +Run   Research
         │     │     │
         └─────┼─────┘
               ▼
    ┌──────────────────────────────────────┐
    │  SwarmOrchestrator                   │
    │  - Select agent(s) by domain         │
    │  - Bootstrap BaseAgent(s)            │
    │  - Execute parallelDelegate()        │
    └──────────────┬───────────────────────┘
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
     agent1      agent2    agent3 ... agent8
    (Weaver)  (Logic)    (Sentinel)
        │        │          │
        └────────┼──────────┘
                 ▼
    ┌──────────────────────────────────────┐
    │  BaseAgent.executeTask()             │
    │  - withRetry() + KeyRotator          │
    │  - Try Model 1, Fail → Model 2       │
    │  - Tool execution + loop detection   │
    │  - Supreme override injection        │
    └──────────────┬───────────────────────┘
                   │
                   ▼
    ┌──────────────────────────────────────┐
    │  KeyRotator                          │
    │  - Get Next Key in Queue             │
    │  - Report Success → move to front    │
    │  - Report Failure → move to back     │
    └──────────────┬───────────────────────┘
                   │
                   ▼
    ┌──────────────────────────────────────┐
    │  Gemini API Call                     │
    │  model, systemInstruction, tools     │
    └──────────────┬───────────────────────┘
                   │
                   ▼
    ┌──────────────────────────────────────┐
    │  Result → Blackboard.post()          │
    │  agent findings stored + persisted   │
    └──────────────┬───────────────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
   Browser (Dexie)      Node (.sAgent_memory/)
   IndexedDB Store      JSON File
        │                     │
        └──────────┬──────────┘
                   ▼
    ┌──────────────────────────────────────┐
    │  SwarmDIS (Error Handler)            │
    │  - Intercept errors from 3 sources   │
    │  - Route to specialist agent         │
    │  - Publish healing status            │
    └──────────────────────────────────────┘
```

## Key Architectural Patterns

### 1. Swarm Orchestration
```typescript
tasks = [
  { agentId: 'agent1', task: 'Design UI component' },
  { agentId: 'agent2', task: 'Implement state logic' },
  { agentId: 'agent3', task: 'Audit security' }
];

results = await orchestrator.parallelDelegate(tasks, concurrency=3);
// All 3 run in parallel, capped at 3 concurrent
```

### 2. Penalty Queue Key Rotation
```typescript
// Initial queue: [key1, key2, key3]
// key1 fails → KeyRotator.reportFailure(key1)
// Queue becomes: [key2, key3, key1]  ← key1 penalized to back
// key2 succeeds → KeyRotator.reportSuccess(key2)
// Queue becomes: [key2, key3, key1]  ← key2 already at front
```

### 3. Blackboard Collaboration
```typescript
// Agent1 posts finding
blackboard.post('agent1', 'api-contract', 'User endpoint returns 200 OK');

// Agent2 queries before executing
const findings = blackboard.read({ topic: 'api-contract' });
// Receives: [{agentId: 'agent1', topic: 'api-contract', content: '...', ...}]
```

### 4. Model Fallback Chain
```typescript
try {
  return await baseAgent.executeTask(prompt);  // Try Pro 3.1
} catch (e) {
  KeyRotator.reportFailure(currentKey);        // Penalize key
  config.apiKeys = KeyRotator.getCombinedQueue(); // Get next key
  ai = new GoogleGenAI({ apiKey: config.apiKeys[0] }); // New AI instance
  throw e;  // Let fallback chain catch it
}
```

### 5. Domain Routing
```typescript
const task = "Fix the CSS animations in React components";
// Keywords detected: ['css', 'animations', 'react']
// Routes to: agent1 (Weaver) - handles UI/Frontend

const task2 = "Optimize database query performance";
// Keywords detected: ['database', 'performance', 'sql']
// Routes to: agent5 (Archivist) + agent4 (Accelerator) if parallel
```

## Risk Analysis Patterns

```typescript
Risk Level  Score Range  Escalation  Example Keywords
──────────  ───────────  ──────────  ──────────────────────────
Low         0-3          None        ['frontend', 'ui', 'styling']
Medium      4-6          Log         ['refactor', 'optimize']
High        7-10         Alert       ['delete', 'security', 'auth', 'payment']
Critical    10+          Block       ['sql-injection', 'xss', 'privilege-escalation']
```

## Persistence Backend Selection

```
Execution Context        Backend              Storage Location
──────────────────────── ──────────────────── ────────────────────────
Browser (Web UI)         Dexie (IndexedDB)    Browser IndexedDB storage
Node.js (Server/CLI)     JSON Files           .sAgent_memory/*.json
──────────────────────── ──────────────────── ────────────────────────

API: Identical for both
  .save(key, data)       → Returns Promise<void>
  .load(key)             → Returns Promise<T|null>
  .delete(key)           → Returns Promise<void>
  .clear()               → Returns Promise<void>
```

## Capability Scoring System

```
Component = 10 capabilities × 5 points = 50 points max
Multimodal = Vision + Veo = 10 points
Baseline = 38 points

Score = baseline + components_enabled * 5 + multimodal_enabled * 10
Maximum = 100
```

## DIS Error Routing Rules

```
Error Keyword Pattern          → Agent Specialist      → Domain
────────────────────────────── ─────────────────────── ───────────────
security, auth, xss, injection → agent3 (Sentinel)     → Security
state, race, null, undefined   → agent2 (Logic Gate)   → Backend
render, component, hook, react → agent1 (Weaver)       → Frontend
memory, leak, performance      → agent4 (Accelerator)  → Performance
database, sql, schema          → agent7 (Mechanic)     → DevOps
network, fetch, api, cors      → agent6 (Inquisitor)   → Networking
fallback (any other)           → agent5 (Archivist)    → Storage/Core
```

## Key Configuration Environment Variables

```bash
# Gemini API Keys
GEMINI_API_KEY              # Primary key
GEMINI_API_KEY_1           # Agent1-specific priority
GEMINI_API_KEY_2           # Agent2-specific priority
GEMINI_API_KEY_3           # ... etc
GEMINI_API_KEY_8           # Agent8-specific priority

# Server Config
PORT                        # Server port (default 3000)
NODE_ENV                    # Environment (development/production)

# Feature Flags
ENABLE_DIS                  # Enable Digital Immune System
ENABLE_SUPREME_PROTOCOL     # Enable Supreme overrides
ENABLE_DEEP_RESEARCH        # Enable Deep tier models
```

## Critical Files for Quick Access

| File | Purpose | LOC |
|------|---------|-----|
| `BaseAgent.ts` | Foundation agent with model fallback | ~400 |
| `SwarmOrchestrator.ts` | 8-agent coordinator | ~300 |
| `Blackboard.ts` | Shared knowledge scratchpad | ~250 |
| `KeyRotator.ts` | Intelligent key rotation | ~80 |
| `PersistenceLayer.ts` | Hybrid Dexie/JSON persistence | ~200 |
| `SwarmDIS.ts` | Self-healing error interceptor | ~300 |
| `Sovereign.ts` | Tier routing and decision making | ~100 |
| `LisaDaemon.ts` | Background health checks + sync | ~150 |
| `AgentRoles.ts` | Role definitions + instructions | ~400 |
| `RiskAnalyzer.ts` | Pattern-based risk scoring | ~30 |

## Integration Checklist

- [ ] LisaDaemon.start() called on server init
- [ ] SwarmOrchestrator.bootSwarm() with API keys
- [ ] Blackboard.loadFromStorage() at startup
- [ ] SwarmDIS.activate() for error handling
- [ ] AutonomousLoop.start() for background tasks
- [ ] hamEventBus subscriptions configured
- [ ] `/api/health` endpoint returns 200
- [ ] COOP/COEP headers present
- [ ] `.lisa/` directory created for logs/metrics
- [ ] Permission checks on supreme_override_command file

## Debugging Commands

```bash
# Check system health
curl http://localhost:3000/api/health

# View Lisa daemon status
curl http://localhost:3000/api/lisa/status

# Check verification results
cat logs/lisa_daemon.log | tail -50

# View Blackboard entries
ls -la .sAgent_memory/blackboard*.json

# View performance metrics
tail -f .lisa/METRICS.jsonl

# View verification log
tail -f .lisa/VERIFICATION_LOG.jsonl

# Check semantic index
cat .lisa/SEMANTIC_INDEX.json | jq '.entries | length'

# Inspect knowledge graph
cat .lisa/KNOWLEDGE_GRAPH.json | jq '.files | length'
```

## Common Issues & Solutions

### Issue: Model keeps failing to respond
**Diagnosis**: Check if API key exhausted or rate-limited
**Solution**: KeyRotator should automatically rotate to next key; check logs for repeated key failures

### Issue: Agents not executing tasks
**Diagnosis**: SwarmOrchestrator not initialized
**Solution**: Ensure `bootSwarm(apiKeys)` called with valid keys before delegating tasks

### Issue: Blackboard entries not persisting
**Diagnosis**: PersistenceLayer not initialized
**Solution**: Call `blackboard.loadFromStorage()` on startup; check `.sAgent_memory/` permissions

### Issue: DIS not healing errors
**Diagnosis**: SwarmDIS not activated
**Solution**: Call `SwarmDIS.activate()` at server init; check hamEventBus connections

### Issue: Agents taking too long
**Diagnosis**: Concurrency too low or model tier too high
**Solution**: Increase concurrency cap in `parallelDelegate(tasks, concurrency=10)` or route to Flash tier

## Performance Optimization Tips

1. **Use parallelDelegate for batch tasks**: 8 agents × concurrency 5 = ~40+ concurrent operations
2. **Route to Flash tier**: ~2-3x faster than Pro tier, use for simple tasks
3. **Batch Blackboard reads**: Read once, share result with multiple agents
4. **Enable persistence**: Avoid re-indexing/re-learning on each restart
5. **Monitor token usage**: Use Treasury system to track Gemini token consumption
6. **Set DIS circuit breaker limits**: Prevent thrashing with 5 fix/minute limit

## Governance & Best Practices

- **Agent Role Isolation**: Never let one agent read/write outside its `contextBoundary`
- **Prohibition Enforcement**: Audit logs when agents attempt prohibited actions
- **Risk Assessment**: Always call `LisaOrchestrator.assess()` before high-risk operations
- **Verification**: Run `LisaOrchestrator.verify()` regularly for system health
- **Key Rotation Monitoring**: Log KeyRotator state for security audits
- **Blackboard Cleanup**: Implement periodic pruning of old entries (>1 hour old)
- **DIS Learning**: Record which agent fixed each error type for pattern learning

---

## Type Definitions Quick Reference

```typescript
// Agent Configuration
interface AgentConfig {
  id: string;
  name: string;
  role: string;
  systemInstruction: string;
  apiKeys: string[];
  priorityKeys?: string[];
}

// Task Delegation
interface AgentTask {
  agentId: string;
  task: string;
}

interface ParallelResult {
  agentId: string;
  agentName: string;
  status: 'ok' | 'error';
  result: string;
  durationMs: number;
}

// Blackboard
interface BlackboardEntry {
  id: string;
  agentId: string;
  topic: string;
  content: string;
  timestamp: number;
  meta?: Record<string, any>;
}

// Risk Analysis
interface RiskAnalysis {
  score: number;
  patterns: string[];
  shouldEscalate: boolean;
}

// DIS Status
interface DISStatus {
  active: boolean;
  healing: boolean;
  totalIntercepted: number;
  totalResolved: number;
  totalSkipped: number;
  recentEvents: DISEvent[];
  lastActivity: number | null;
}

// Persona
interface Persona {
  id: string;
  name: string;
  domain: string;
  systemInstruction: string;
  preferredTier: 'pro' | 'flash' | 'deep';
  tools: string[];
}

// Sovereign
interface RouteDecision {
  tier: 'pro' | 'flash' | 'deep';
  capabilities: string[];
  persona?: string;
  destructive: boolean;
  reasoning: string;
}
```

---

## Operational Runbook

### Startup Sequence
1. Server.ts boot
2. → LisaDaemon.start() (background health checks)
3. → SwarmOrchestrator.bootSwarm(keys) (initialize 8 agents)
4. → Blackboard.loadFromStorage() (restore session knowledge)
5. → SwarmDIS.activate() (error interception enabled)
6. → AutonomousLoop.start() (background health audits)

### Task Execution Sequence
1. User request → LisaOrchestrator.assess(task) [risk check]
2. → Sovereign.execute(task) [router]
3. → SwarmOrchestrator.parallelDelegate(tasks) [dispatch]
4. → BaseAgent.executeTask() × N agents [parallel execution]
5. → Blackboard.post() [publish findings]
6. → PersistenceLayer.save() [async persist to Dexie/JSON]
7. → Result aggregation + return to user

### Error Recovery Sequence
1. BaseAgent.executeTask() fails
2. → withRetry() catches error
3. → KeyRotator.reportFailure(failedKey)
4. → Tries next key + next model tier
5. → If still fails → SwarmDIS.intercept(errorMsg)
6. → SwarmDIS routes to specialist agent (e.g., sentinel for security error)
7. → Specialist agent generates fix
8. → SwarmDIS.publish(fix) to Blackboard
9. → UI displays healing action taken

### Monitoring & Maintenance
- Every 5 minutes: Check daemon health via hamEventBus heartbeat
- Every hour: LisaDaemon.syncGeminiKeys() updates key pool
- Every session: LisaOrchestrator.verify() runs system checks
- On errors: SwarmDIS logs to Blackboard + publishing healing status
- On shutdown: Save all Blackboard entries via persistence
