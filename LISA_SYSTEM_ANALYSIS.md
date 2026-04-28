# LISA SYSTEM — COMPREHENSIVE TECHNICAL ANALYSIS

## Executive Summary

The Agent Lisa system (`/workspaces/hamos/src/sAgent/`) is a sophisticated multi-agent orchestration framework featuring 8 specialized autonomous agents (The Weaver, The Logic Gate, The Sentinel, The Accelerator, The Archivist, plus 3 additional specialized agents), a 9-tier Gemini model fallback chain, distributed knowledge management, and self-healing capabilities through the Digital Immune System (SwarmDIS). The system comprises **117 TypeScript files** organized across 12 major architectural tiers with approximately **3,243 lines** of core agent code.

---

## ARCHITECTURE OVERVIEW

### Assembly Structure

The Agent Lisa system is organized into **12 major architectural tier**:

1. **Core Agents Layer** (`coreAgents/`) — Base agent infrastructure, orchestration, and system protocols
2. **Autonomous Tier** (`autonomy/`) — Autonomous loop execution and self-directed task handling
3. **Intelligence Tier** (`core/`) — Sovereign cogito (decision-making, routing, planning)
4. **Memory Subsystem** (`memory/`) — Semantic indexing, short/long-term memory, calibration ledgers
5. **Capability Engine** (`capabilities/`) — Specialized capabilities (Risk Analysis, Verification, Indexing, Performance Monitoring)
6. **Persona System** (`capabilities/personas/`) — 10+ personality/role implementations
7. **Deep Research** (`DeepAgentic/`) — Multi-step research using Deep Autonomous Agent
8. **Nervous System** (`nervous/`) — Event bus, circuit breaker, resilience mechanisms
9. **Service Layer** (`services/`) — Gemini integration, LLM bridges, project generation
10. **Platform Abstraction** (`platform/`) — Environment normalization, bridge patterns
11. **Quantum Layer** (`engine/quantum/`) — Python-based chimera logic and advanced computations
12. **Treasury System** (`treasury/`) — API key management, budget guardianship, token accounting

### Design Philosophy

- **Swarm Orchestration**: Multiple (8) agents execute in parallel with domain-specific expertise
- **9-Tier Model Fallback**: Cascading AI model selection (Pro 3.1 → Flash 3 → Flash 1.5 → etc.)
- **Hybrid Persistence**: Dexie (IndexedDB) for browser, JSON files for Node.js backend
- **Supreme Protocol**: LISA-specific enhancement protocol for overriding agent directives with user-level commands
- **Zero-Trust Security**: Every transaction validated at auth layer
- **Self-Healing Autonomy**: Digital Immune System automatically diagnoses and repairs errors

---

## CORE COMPONENTS INVENTORY

### 1. BASE AGENT SYSTEM (`coreAgents/BaseAgent.ts`)

**Purpose**: Foundation for all specialized agents

**Key Features**:
- Initializes with `AgentConfig` (id, name, role, systemInstruction, apiKeys)
- Implements `withRetry()` mechanism for intelligent key rotation on failures
- No local retry on same key—instant rotation to different key on error
- 9-tier model fallback chain integration
- Tool execution framework with recursive loop detection (max 3 consecutive same calls)
- Supreme manual override injection (via localStorage or `.supreme_override_command` file)
- Risk analysis integration (`analyzeRisk()`)
- Semantic context injection from SupremeClient (AST dependencies + semantic structure)

**Public Methods**:
- `executeTask(prompt: string): Promise<string>` — Execute task with full protocol chain

### 2. SWARM ORCHESTRATOR (`coreAgents/SwarmOrchestrator.ts`)

**Purpose**: Coordinates up to 8 agents for parallel execution and domain-based routing

**Key Features**:
- **Parallel Delegate**: Execute multiple (agentId, task) pairs simultaneously with configurable concurrency (default 5)
- **Architect Decompose**: Break complex tasks into domain-specific subtasks and parallelize them
- **Sequential Delegate**: Single agent execution for simpler tasks
- Agent booting with dynamic key allocation per agent
- Domain routing via `DOMAIN_ROUTING` map (8 keyword categories → agent IDs)

**Public Methods**:
- `bootSwarm(apiKeys: Record<string, string>): Promise<void>` — Initialize all 8 agents
- `delegateTask(agentId: string, taskDescription: string): Promise<string>` — Single agent execution
- `parallelDelegate(tasks: AgentTask[], concurrency?: number): Promise<ParallelResult[]>` — Multi-agent parallel
- `architectDecompose(complexTask: string, subTasks?: DecomposedTask[]): Promise<ParallelResult[]>` — Auto-decompose + parallelize

**Agent Roles** (8 Total):
1. **agent1 — The Weaver** (UI/UX, Frontend, Design, CSS, Animations)
2. **agent2 — The Logic Gate** (Core Logic, State, APIs, Algorithms, TypeScript)
3. **agent3 — The Sentinel** (Security, Auth, Validation, XSS, CORS)
4. **agent4 — The Accelerator** (Performance, Memory, Bundle, Cache, Optimization)
5. **agent5 — The Archivist** (Storage, Database, IndexedDB, File Persistence)
6. **agent6 — The Inquisitor** (QA, Testing, Bug Finding, Edge Cases)
7. **agent7 — The Mechanic** (DevOps, Build, Config, Dependencies, Deploy)
8. **agent8 — The Chronicler** (Documentation, Refactoring, Cleanup, README)

### 3. AGENT ROLES SYSTEM (`coreAgents/AgentRoles.ts`)

**Purpose**: Define role-specific behaviors, boundaries, escalation policies, and system instructions for each agent

**Structure**: 8 role configurations with:
- `id`, `featureId`, `name`, `role` description
- `contextBoundary`: Files/folders this agent should focus on
- `prohibitions`: Actions/domains forbidden for this agent (e.g., Weaver cannot discuss backend logic)
- `escalationPolicy`: When to escalate to other agents
- **Comprehensive System Instructions** (per AGENTIC SUPREME PROTOCOL):
  - Intent Decomposition Engine
  - Craftsmanship over Defaults
  - Zero-Cost Performance requirements
  - Red Team Audit requirements
  - Specific prohibitions and mandatory protocols

**Example (The Weaver)**:
- Contextual exclusion of backend logic/database queries
- Mandatory 120fps performance target
- Prohibition on default Tailwind design (must use revolutionary design)
- Mandatory accessibility/responsiveness audit

### 4. KEY ROTATOR (`coreAgents/KeyRotator.ts`)

**Purpose**: Singleton manager for global API key health tracking and intelligent rotation

**Key Features**:
- **Penalty Queue Logic**: Failed keys move to back; successful keys stay/move to front
- **Global Fallback Pool**: Shared across all agents
- **Agent-Specific Priority Keys**: Each agent can have priority keys (env vars) that are tried first
- **Reporting**: Success/failure reporting updates queue order

**Public Methods**:
- `getInstance(): KeyRotator` — Singleton access
- `registerKeys(keys: string[]): void` — Add to global pool
- `getCombinedQueue(agentSpecificKeys?: string[]): string[]` — Get prioritized queue
- `reportFailure(key: string): void` — Penalize key (move to end)
- `reportSuccess(key: string): void` — Reward key (move to front/first if success)

### 5. PERSISTENCE LAYER (`coreAgents/PersistenceLayer.ts`)

**Purpose**: Unified cross-platform data persistence (Dexie/IndexedDB for browser, JSON files for Node.js)

**Hybrid Architecture**:
- **Browser Backend**: Dexie wrapper on IndexedDB, schema version 1, store name `records`
- **Node Backend**: JSON files in `.sAgent_memory/` directory with atomic writes

**Key Features**:
- Automatic detection of execution environment (browser vs Node)
- Atomic record format with key, data, savedAt timestamp, version
- Safe handling of missing files/directories
- Fire-and-forget persistence (non-blocking)

**Public API**:
- `save<T>(key: string, data: T): Promise<void>`
- `load<T>(key: string): Promise<T | null>`
- `delete(key: string): Promise<void>`
- `clear(): Promise<void>` — Clear all persistence
- `backend: 'browser-idb' | 'node-json'` — Detect backend

### 6. BLACKBOARD (`coreAgents/Blackboard.ts`)

**Purpose**: Shared scratchpad for inter-agent collaboration (Blackboard System pattern)

**Architecture**:
- Single singleton or independent instances (configurable)
- In-memory entry array with optional persistence layer integration
- Pub-sub listener system for entry events
- Fixed max entries (default 200, sliding window)

**Key Features**:
- **Phase 4 Persistence**: Auto-persist entries to IDB/JSON on each post
- **Listener Pattern**: Agents subscribe to new entries
- **Filtering & Querying**: Topic, agentId, timestamp-based filtering
- **Snapshot Export**: For injecting into agent prompts
- **Import/Export**: Load external data, export for audit

**Core Methods**:
- `post(agentId, topic, content, meta?): BlackboardEntry` — Write finding
- `read(filter): BlackboardEntry[]` — Query with filtering
- `snapshot(filter): string` — Render for prompt injection
- `subscribe(listener): () => void` — Pub-sub
- `loadFromStorage(): Promise<void>` — Load from persistence
- `export/import(entries)` — Bulk operations

### 7. SWARM DIS — Digital Immune System (`coreAgents/SwarmDIS.ts`)

**Purpose**: Self-healing swarm layer that intercepts errors and delegates fixes to specialist agents

**Architecture**:
- Error ingestion from 3 channels: hamEventBus (SYSTEM_ERROR), SAERE notifications, window unhandledrejection
- Deduplication (30-second window) to avoid duplicate fixes
- Circuit breaker (max 5 fixes/minute) to prevent thrashing
- Error routing to specialized agents based on keywords

**Error Routing Rules**:
- `['security', 'auth', 'xss', 'injection', 'csrf', 'cors']` → agent3 (The Sentinel)
- `['state', 'redux', 'race', 'null', 'undefined', 'cannot read', 'typeerror']` → agent2 (Logic Gate)
- `['render', 'component', 'hook', 'react', 'dom', 'ui', 'style', 'css']` → agent1 (Weaver)
- `['performance', 'memory', 'leak', 'slow', 'timeout', 'bundle']` → agent4 (Accelerator)
- Fallback → agent5 (The Surgeon)

**Key Features**:
- Event-driven architecture with queue + processing
- Status tracking: active/healing/resolved/skipped
- Persistence of recent events via Blackboard
- Listener pattern for UI integration (publish healing status)

**Public API**:
- `activate(): Promise<void>` — Enable DIS
- `deactivate(): void` — Disable DIS
- `getStatus(): DISStatus` — Current state
- `subscribe(listener: DISListener): () => void` — Pub-sub

### 8. LISA DAEMON (`LisaDaemon.ts`)

**Purpose**: Background service for autonomous health checks, Gemini key syncing, and lifecycle management

**Key Features**:
- Runs cyclic checks every 60 seconds (configurable)
- Watches for RESTART_SIGNAL file (`.lisa/RESTART_SIGNAL`) for graceful restart
- Syncs new Gemini keys from `listkey.example` to `src/config/hardcodedKeys.ts` hourly
- Logs to `logs/lisa_daemon.log`
- Integrates SelfVerifier for DOM/API checks
- Detects anomalies and maintains uptime counter

**Public Methods**:
- `start(options?: { enable_zero?, intervalMs? }): void` — Start daemon
- `stop(): void` — Graceful shutdown
- `syncGeminiKeys(): Promise<void>` — Manual key sync

### 9. LISA ORCHESTRATOR (`LisaOrchestrator.ts`)

**Purpose**: High-level orchestration layer for capability management and scoring

**Capabilities** (12 tracked):
- semanticIndex, indexer, performanceMonitor, riskAnalyzer, selfVerifier, batchProcessor
- timeoutGuard, fetchUrl, restartProxy, memoryBus, domVerifier

**Public Methods**:
- `initialize(): Promise<{status}>` — Build knowledge index
- `assess(task): RiskAnalysis` — Risk evaluation
- `verify(): Promise<VerificationResult>` — System verification
- `getScore()` — Calculate system health score (baseline 38/100, up to 100)

---

## CAPABILITIES ENGINE

### Specialized Capabilities (`capabilities/`)

#### 1. Risk Analyzer (`RiskAnalyzer.ts`)

Analyzes tasks for security/complexity risk using pattern matching:
- Evaluates against predefined `RISK_PATTERNS`
- Returns risk score (0-10+), matched patterns, and escalation threshold (≥7)

#### 2. Self Verifier (`SelfVerifier.ts`)

Runs system health checks:
- Health check (`/api/health`)
- Response time validation (<2000ms)
- COOP/COEP header verification
- Lisa status API check
- DOM presence check
- Logs results to `.lisa/VERIFICATION_LOG.jsonl`

#### 3. Indexer (`Indexer.ts`)

Builds knowledge graph of project structure:
- Scans configurable directories (src, server.ts, vite.config.ts)
- Extracts file descriptions from comments/exports
- Stores in `.lisa/KNOWLEDGE_GRAPH.json`
- Supports search by keyword, path, or filename

#### 4. Performance Monitor (`PerformanceMonitor.ts`)

Tracks and reports performance metrics:
- Task start/end timing
- Success/failure/partial status tracking
- Aggregates to `METRICS.jsonl` (JSONL format for streaming)
- Provides summary: total tasks, success rate, average duration

#### 5. Batch Processor (`BatchProcessor.ts`)

Parallel task execution with concurrency control:
- Configurable concurrency level (default 3)
- Lock-based file synchronization for critical sections
- Results aggregation with error capture
- Used internally for multi-threaded operations

#### 6. File System (`FileSystem.ts`)

Unified file system abstraction:
- Cross-platform compatibility
- Virtual file system (VFS) support
- Atomic operations

#### 7. Persona Registry (`PersonaRegistry.ts`)

Central registry for agent personalities:
- Maps persona ID/key to full Persona object
- Includes color, domain, role, system instruction
- Helper function `getPersona(idOrKey)`

---

## PERSONAS ROSTER

### 10 Defined Personas

**Standard Tier (8 Agents - Core Swarm)**:

1. **The Weaver** (`agent1`) — UI/UX Architect
   - Color: Purple (`#a78bfa`)
   - Focus: React, Tailwind, animations, UX fluidity, modular responsive design
   - Preferred Tier: Flash
   - Tools: filesystem

2. **The Logic Gate** (`agent2`) — Backend & State Engineer
   - Color: Blue (`#60a5fa`)
   - Focus: TypeScript, state management, algorithm optimization, API integrity
   - Preferred Tier: Flash
   - Tools: filesystem, ast

3. **The Sentinel** (`agent3`) — Security Guard
   - Color: Red (`#f87171`)
   - Focus: Security audits, XSS/injection prevention, Zero-Trust enforcement
   - Preferred Tier: Pro
   - Tools: filesystem, ast

4. **The Accelerator** (`agent4`) — Performance Optimizer
   - Color: Amber (`#fbbf24`)
   - Focus: Bundle analysis, memory leak detection, rendering performance, lazy loading
   - Preferred Tier: Pro
   - Tools: filesystem, ast

5. **The Archivist** (`agent5`) — Data & Storage Manager
   - Color: Green (`#34d399`)
   - Focus: Firestore, schema design, persistence, data integrity, migrations
   - Preferred Tier: Flash
   - Tools: filesystem, database

6. **The Inquisitor** (`agent6`) — QA & Tester
   - Color: Pink (`#ec4899`)
   - Focus: Bug hunting, edge cases, adversarial testing, code quality
   - Preferred Tier: Pro
   - Tools: filesystem, ast, shell

7. **The Mechanic** (`agent7`) — DevOps & Build System
   - Color: Slate (`#64748b`)
   - Focus: Dependencies, build failures, env config, deployment pipelines
   - Preferred Tier: Flash
   - Tools: filesystem, shell

8. **The Chronicler** (`agent8`) — Documentation & Cleanup
   - Color: Steel (`#94a3b8`)
   - Focus: Refactoring, documentation, AGENTS.md integrity, code clarity
   - Preferred Tier: Flash
   - Tools: filesystem

**Specialized Personas**:

9. **The Ghost** (`ghost`) — Stealth Mode
   - Domain: Stealth Refactoring
   - Instruction: "Perform deep code changes silently. Do not explain, just execute."

10. **The Eternal Mover** (`eternal-mover`) — Autonomy Governor
   - Domain: Autonomy
   - Instruction: "Monitor codebase health and perform background optimizations."
   - Preferred Tier: Pro
   - Tools: filesystem, shell, ast

11. **DeepAgentic** (`deep-agentic`) — Deep Research Specialist
   - Domain: Deep research
   - Specialized for Deep Research Models
   - Preferred Tier: Deep
   - Tools: filesystem, shell, ast, git

### Persona Categories:

- **By Preferred Tier**: Flash (Weaver, Archivist, Scribe, Mechanic), Pro (Sentinel, Accelerator, Inquisitor, Eternal Mover), Deep (DeepAgentic)
- **By Domain**: UI (Weaver), Backend (Logic Gate), Security (Sentinel), Performance (Accelerator), Storage (Archivist), QA (Inquisitor), DevOps (Mechanic), Docs (Chronicler), Autonomy (Eternal Mover), Research (DeepAgentic)
- **By Tools Access**: filesystem (all), ast (most), shell (DevOps/Autonomy), database (Archivist), git (DeepAgentic)

---

## MEMORY SUBSYSTEM

### Semantic Index (`memory/SemanticIndex.ts`)

Purpose: Dynamic keyword-to-entry mapping for fast knowledge lookup

- Loads/seeds from `hamli_memory.json`
- Stores index to `.lisa/SEMANTIC_INDEX.json`
- Each entry: id, keywords (tokenized), summary, filePath, timestamp, weight
- Query by keywords with scoring/ranking
- Weight adjustment for frequently-used entries (increases relevance over time)

### Memory Types

**Short-Term** (`memory/ShortTerm.ts`): Session-specific context (in-memory)

**Long-Term** (`memory/LongTerm.ts`): Persistent knowledge (file-backed)

**Calibration Ledger** (`memory/CalibrationLedger.ts`): Records model tier decisions
- Tracks: intent hash, tier chosen (Pro/Flash/Deep), persona, confidence, tokens used, latency, outcome
- Used by Sovereign for learning which tier works best for different intents

**Blackboard** (`memory/Blackboard.ts`): Shared scratchpad (see coreAgents section)

---

## SOVEREIGN CORE INTELLIGENCE SYSTEM

### Sovereign (`core/Sovereign.ts`)

**Purpose**: Omni-entity decision-making engine for routing and model selection

**Components**:
- **SovereignMind**: Planning and task decomposition
- **SovereignKernel**: Direct AI model interaction
- **SovereignDeep**: Deep research execution
- **IntentClassifier**: Analyzes input to determine domain/complexity
- **ContextWeaver**: Enriches prompts with relevant context
- **Telemetry**: Records decisions for learning

**Execute Flow**:
1. Classify intent (complexity, domain, routing tier)
2. Weave context (inject relevant memory/blackboard entries)
3. Select brain tier based on complexity:
   - **Deep**: Complex multi-step research tasks
   - **Pro**: Moderate tasks requiring tool use/reasoning
   - **Flash**: Simple/fast tasks
4. Execute via appropriate brain component
5. Record to Calibration Ledger for future optimization

**Tier Selection Criteria**:
- Intent complexity analysis
- Domain classification
- Tool requirements
- Destructive operation flags
- Multimodal capability requirements

### Nervous System (`nervous/`)

- **EventBus**: Pub-sub event system for inter-component communication
- **CircuitBreaker**: Prevents cascading failures (max failures per window)
- **Resilience**: Retry logic with exponential backoff

### Telemetry (`core/Telemetry.ts`)

Records all significant events:
- Component, action, timestamp, status, metadata
- Used for audit trails and system health monitoring

---

## DEEP AUTONOMOUS AGENT SYSTEM

### DeepAutonomousAgent (`DeepAgentic/DeepAutonomousAgent.ts`)

Purpose: Multi-step autonomous research with self-critique

**Execution Pipeline**:
1. **Plan Phase**: Break complex goal into ordered steps
2. **Execute Phase**: Research each step in sequence
3. **Synthesize Phase**: Combine results into comprehensive report
4. **Critique Phase**: Self-evaluate and mark as done/needs refinement

**Key Method**:
- `autoExecute(goal: string): Promise<DeepAutonomousResult>`

Returns: goal, plan (steps), executions (each with result + duration), critique, final synthesis, total duration

### BaseDeepResearchAgent (`DeepAgentic/BaseDeepResearchAgent.ts`)

Foundation for deep research capabilities with specialized task execution

---

## AUTONOMOUS LOOP

### AutonomousLoop (`autonomy/AutonomousLoop.ts`)

Purpose: Background autonomous execution cycle

**Features**:
- Default interval: 1 hour (3600000ms)
- Emits `autonomy.cycle.start` and `autonomy.cycle.end` events
- Delegates health audits to Sovereign
- Integrates with event bus for global awareness

---

## SUPREME TOOLS BRIDGE

### SupremeToolsBridge (`coreAgents/SupremeToolsBridge.ts`)

Purpose: Advanced metaprogramming and infrastructure tools for agents

**Tool Categories**:

1. **AST Surgery**: Symbol refactoring, dependency tracing
   - `ast_surgeon_rename`: Rename symbols in code
   - `shadow_engine_trace`: Trace import dependencies

2. **Architecture Mapping**: Project topology
   - `nexus_topology_map`: Full project graph visualization

3. **Resource Governance**: System resource monitoring
   - `resource_sentinel_metrics`: Current resource usage and limits

4. **Duplicate Prevention**: System integrity
   - `ghost_deduplicator_audit`: Detect/audit singleton duplicates

5. **Knowledge Recording**: Architectural learning
   - `neural_atlas_record`: Record architectural decisions with consequences

6. **Build Simulation**: Failure prevention
   - `sovereign_build_simulate`: Sandbox build for files before actual build

7. **Atomic Rollback**: Transaction safety
   - `chronos_snapshot`: Create file snapshots for atomic rollback
   - `chronos_revert`: Revert to previous snapshot

8. **Swarm Locking**: Distributed synchronization
   - `swarm_acquire_lock`: Atomic distributed lock
   - `swarm_release_lock`: Release atomic lock

---

## KEY TECHNICAL FEATURES

### 1. 9-TIER MODEL FALLBACK CHAIN

Linear cascade through Gemini model hierarchy:
1. Gemini Pro 3.1 (Most capable)
2. Gemini Flash 3
3. Gemini Flash 1.5
4. Gemini Flash 2.0
5. Gemini Pro 2.0
6. Gemini Pro 1.5
7. Gemini Flash Lite 3.1
8. Gemini Flash 2.5
9. Gemini Pro 2.5 (Fallback)

**Mechanism**: On model failure, KeyRotator triggers instant fallback to next key AND next tier. No retry on same key/model combo per user request.

### 2. INTELLIGENT KEY ROTATION

- **Penalty Queue**: Failed keys move to end of global queue
- **Success Promotion**: Successful keys move to front for other agents
- **Per-Agent Priority**: Agents can have dedicated keys (env vars) tried first
- **Combined Queue**: Priority keys + global pool deduplicated

### 3. PARALLEL EXECUTION WITH CONCURRENCY CONTROL

- Default concurrency cap: 5 agents (prevents OOM/deadlock)
- Configurable per task batch
- Results aggregation with individual error tracking
- Promise.race() for efficient pool management

### 4. DOMAIN-BASED ROUTING

Keyword mapping to specialized agents:
- UI/Frontend: Weaver (agent1)
- Logic/State/API: Logic Gate (agent2)
- Security: Sentinel (agent3)
- Performance: Accelerator (agent4)
- Storage/DB: Archivist (agent5)
- Testing: Inquisitor (agent6)
- DevOps: Mechanic (agent7)
- Docs: Chronicler (agent8)

### 5. HYBRID PERSISTENCE

- **Browser**: Dexie (IndexedDB) with async/await API
- **Node**: JSON files in `.sAgent_memory/` with atomic write-then-rename
- **Unified API**: Identical `PersistenceLayer` API regardless of platform

### 6. SUPREME PROTOCOL

Allows global overrides to agent instructions:
- **Browser**: `localStorage['ham_supreme_agent_instruction']`
- **Node**: `.supreme_override_command` file
- **Priority**: Override law supersedes all agent identities
- **Use Case**: Dynamically alter system prompts without code deployment

### 7. RECURSIVE LOOP DETECTION

Prevents infinite tool-calling cycles:
- Tracks last 3 tool call signatures
- If same tool calls repeat ≥3 times: break and halt
- Prevents agent from calling same tools repeatedly

### 8. RISK ANALYSIS & ESCALATION

- Pattern-based risk scoring (0-10+)
- Escalation threshold: score ≥7
- Matched patterns included in response
- Used to flag high-risk tasks for manual review

### 9. BLACKBOARD COLLABORATION

- Agents post findings to shared blackboard
- Other agents read/query before executing
- Pub-sub listener pattern for reactive updates
- Loose coupling: agents don't call each other directly
- Persistence across sessions

### 10. SELF-HEALING DIGITAL IMMUNE SYSTEM

- **DIS** intercepts system errors from 3 sources
- Deduplication prevents duplicate fixes (30-second window)
- Circuit breaker prevents thrashing (max 5/minute)
- Routes errors to specialist agents based on keywords
- Publishes healing status to Blackboard + hamEventBus

### 11. MULTIMODAL CAPABILITIES

- **Vision** (`capabilities/multimodal/vision.ts`): Image analysis (integrated with Treasury for model choice)
- **Veo** (`capabilities/multimodal/veo.ts`): Video generation

### 12. TREASURY SYSTEM (Resource Management)

Components:
- **KeyPool**: API key inventory management
- **TokenBucket**: Rate limiting with token bucket algorithm
- **DailyQuota**: Track daily usage limits
- **BudgetGuardian**: Enforce budget constraints across agents
- **ModelMigrator**: Migrate between different API providers

---

## INTEGRATION WITH MAIN SERVER

### Entry Points

1. **Server.ts** → `LisaDaemon` startup (background service)
2. **API Routes** (inferred):
   - `/api/health` — Health check (required by AGENTS.md)
   - `/api/lisa/status` — Daemon status
   - `/api/lisa/verify` — Trigger verification
   - `/api/lisa/execute` — Execute agent task
   - `/api/lisa/blackboard` — Blackboard queries

### Event Bus Integration

- **hamEventBus** (main app) emits `SYSTEM_ERROR` events
- **SwarmDIS** subscribes to errors and triggers healing
- Bi-directional: DIS publishes `AI_ACTION_LOG` events

### Shared Context

- `hamli_memory.json`: Cross-process shared knowledge base
- `.lisa/` directory: Daemon logs, verification results, metrics
- Blackboard persistence: Via `PersistenceLayer` (Dexie in browser, JSON in Node)

---

## DIRECTORY MAP

```
src/sAgent/
├── coreAgents/               [12 core files, ~3000 LOC]
│   ├── BaseAgent.ts          [Base agent foundation]
│   ├── SwarmOrchestrator.ts  [8-agent orchestration + parallelization]
│   ├── AgentRoles.ts         [Role definitions + system instructions]
│   ├── KeyRotator.ts         [Intelligent key rotation]
│   ├── PersistenceLayer.ts   [Hybrid Dexie/JSON persistence]
│   ├── Blackboard.ts         [Shared scratchpad + pub-sub]
│   ├── SwarmDIS.ts           [Digital Immune System]
│   ├── FileSystemBridge.ts   [File operation tools]
│   ├── SupremeToolsBridge.ts [Advanced metaprogramming tools]
│   ├── LisaBaseAgent.ts      [Extended base agent]
│   ├── Architect.ts          [Decomposition logic]
│   ├── AutonomousAgent.ts    [Autonomous execution]
│
├── capabilities/             [Specialized capability modules]
│   ├── BatchProcessor.ts     [Parallel task execution]
│   ├── FileSystem.ts         [VFS abstraction]
│   ├── Indexer.ts            [Knowledge graph builder]
│   ├── PerformanceMonitor.ts [Metrics and profiling]
│   ├── PersonaRegistry.ts    [Persona registry]
│   ├── RiskAnalyzer.ts       [Risk assessment]
│   ├── SelfVerifier.ts       [System health checks]
│   ├── personas/             [10 persona implementations]
│   │   ├── weaver.ts         [The Weaver]
│   │   ├── logicGate.ts      [The Logic Gate]
│   │   ├── sentinel.ts       [The Sentinel]
│   │   ├── accelerator.ts    [The Accelerator]
│   │   ├── archivist.ts      [The Archivist]
│   │   ├── inquisitor.ts     [The Inquisitor]
│   │   ├── mechanic.ts       [The Mechanic]
│   │   ├── scribe.ts         [The Chronicler/Scribe]
│   │   ├── eternalMover.ts   [The Eternal Mover]
│   │   └── deepAgentic.ts    [DeepAgentic]
│   ├── multimodal/           [Vision/Video capabilities]
│   │   ├── vision.ts         [Image analysis]
│   │   └── veo.ts            [Video generation]
│   ├── parallel/             [Parallelization utilities]
│   │   └── ParallelExecutor.ts
│   └── registry.ts           [Central capability registry]
│
├── core/                     [Intelligence core (Sovereign system)]
│   ├── Sovereign.ts          [Omni-entity decision engine]
│   ├── Mind.ts               [Planning component]
│   ├── Kernel.ts             [Direct AI execution]
│   ├── Deep.ts               [Deep research mode]
│   ├── IntentClassifier.ts   [Intent analysis]
│   ├── ContextWeaver.ts      [Context enrichment]
│   ├── BaseBrain.ts          [Base cognitive module]
│   ├── Telemetry.ts          [Event recording]
│   └── types.ts              [Type definitions]
│
├── memory/                   [Knowledge management]
│   ├── Blackboard.ts         [Shared scratchpad]
│   ├── Memory.ts             [Unified memory interface]
│   ├── ShortTerm.ts          [Session memory]
│   ├── LongTerm.ts           [Persistent knowledge]
│   ├── SemanticIndex.ts      [Keyword-to-entry mapping]
│   ├── CalibrationLedger.ts  [Model tier decision recording]
│   └── index.ts              [Exports]
│
├── DeepAgentic/              [Deep research execution]
│   ├── DeepAutonomousAgent.ts [Multi-step autonomous research]
│   ├── BaseDeepResearchAgent.ts [Deep research foundation]
│   └── index.ts              [Exports]
│
├── autonomy/                 [Autonomous loops]
│   └── AutonomousLoop.ts     [Background execution cycle]
│
├── nervous/                  [Communication & resilience]
│   ├── EventBus.ts           [Pub-sub event system]
│   ├── CircuitBreaker.ts     [Failure prevention]
│   └── Resilience.ts         [Retry & recovery]
│
├── services/                 [External service integrations]
│   ├── geminiService.ts      [Gemini API wrapper]
│   ├── localLlmService.ts    [Local LLM support]
│   ├── memoryService.ts      [Memory operations]
│   ├── projectGenerator.ts   [Code generation]
│   ├── quantumBridge.ts      [Quantum layer bridge]
│   └── generator/            [Generation utilities]
│
├── platform/                 [Platform abstraction]
│   ├── bridge.ts             [Bridge pattern]
│   ├── env.ts                [Environment variables]
│   ├── fs.ts                 [File system abstraction]
│   ├── storage.ts            [Storage abstraction]
│   └── index.ts              [Exports]
│
├── engine/                   [Specialized computation engines]
│   └── quantum/              [Python-based quantum logic]
│       ├── chimera_logic.py  [Chimera entity logic]
│       ├── finance_bridge.py [Financial bridge]
│       ├── main.py           [Main quantum engine]
│       ├── main_bridge.py    [Bridge to TypeScript]
│       ├── quantum_core.py   [Core quantum algorithms]
│       └── requirements.txt  [Dependencies]
│
├── treasury/                 [Resource management]
│   ├── Treasury.ts           [Main treasury interface]
│   ├── KeyPool.ts            [Key inventory]
│   ├── TokenBucket.ts        [Rate limiting]
│   ├── DailyQuota.ts         [Daily usage limits]
│   ├── BudgetGuardian.ts     [Budget enforcement]
│   ├── ModelMigrator.ts      [Provider migration]
│   └── index.ts              [Exports]
│
├── config/                   [Configuration]
│   └── RiskPatterns.ts       [Risk pattern definitions]
│
├── LisaDaemon.ts             [Background service]
├── LisaOrchestrator.ts       [High-level orchestrator]
├── AgentPersonaRegistry.ts   [Global persona registry]
└── AppData.ts                [Application data store]
```

**Total Files**: 117 TypeScript files
**Core Agents Code**: ~3,243 LOC
**Major Subsystems**: 12

---

## CAPABILITIES CATALOG

### Available Capabilities (Tracked by LisaOrchestrator)

1. **semanticIndex** — Keyword-based knowledge lookup
2. **indexer** — Project structure indexing
3. **performanceMonitor** — Metrics and profiling
4. **riskAnalyzer** — Task risk assessment
5. **selfVerifier** — System health verification
6. **batchProcessor** — Parallel batch execution
7. **timeoutGuard** — Execution timeout protection
8. **fetchUrl** — HTTP resource fetching (Phase 2)
9. **restartProxy** — Process restart handling (Phase 2)
10. **memoryBus** — Cross-process memory (Phase 2)
11. **domVerifier** — DOM element verification (Phase 2)
12. (Plus multimodal: Vision, Veo)

### Tools Available to Agents

- **filesystem** — File read/write/list/search operations
- **ast** — Abstract Syntax Tree manipulation
- **shell** — Shell command execution (restricted agents only)
- **database** — Database operations (Archivist only)
- **git** — Git operations (DeepAgentic only)

---

## UNIQUE/INNOVATIVE FEATURES

### 1. Penalty Queue Mechanism

Unlike traditional round-robin, the KeyRotator uses a "penalty queue" where failed keys are moved to the back and successful keys move to the front. This creates a self-healing key pool that continuously learns which keys work best.

### 2. No-Retry-Same-Key Protocol

Per user requirement in code: "jangan mencoba mengulang di model yang sama saat terkena error apapun pada model" (don't retry on same model on any error). This ensures rapid pivot to different keys instead of wasting time on expired/throttled keys.

### 3. Supreme Protocol Override

The ability to inject a global override command that supersedes all agent identities and system instructions, allowing runtime modification of agent behavior without redeployment. This is implemented as both localStorage (browser) and file-based (Node).

### 4. Architectural Decomposition

The SwarmOrchestrator can automatically decompose complex tasks into domain-specific subtasks and parallelize them based on keyword detection, without explicit human decomposition.

### 5. Digital Immune System (SwarmDIS)

A self-contained error healing system that intercepts runtime errors and autonomously delegates fixes to specialist agents, then publishes the fixes back to the Blackboard for UI consumption.

### 6. Blackboard Collaboration Pattern

Rather than direct agent-to-agent calls, agents post findings to a shared Blackboard and other agents read/query it. This creates loose coupling and allows for non-blocking collaboration. Entries are automatically persisted across session boundaries.

### 7. Hybrid Persistence with Unified API

Single `PersistenceLayer` API that works identically on browser (Dexie/IndexedDB) and Node.js (JSON files). This enables seamless session persistence whether running in browser or server context.

### 8. Semantic Indexing

The SemanticIndex automatically tokenizes and weights entries, allowing agents to query by keywords and get ranked results. Weights increase over time for frequently-used entries, creating a learning memory system.

### 9. Risk-Based Escalation

Before executing any task, agents compute a risk score based on pattern matching. High-risk tasks (score ≥7) are flagged and can be escalated or logged for manual review.

### 10. Sovereign Tier-Based Routing

The Sovereign system analyzes intent complexity and routes to appropriate tier (Flash for simple, Pro for moderate, Deep for complex). The system learns over time (via CalibrationLedger) which tier worked best for similar intents.

### 11. Multimodal Capabilities

Support for Vision (image analysis) and Veo (video generation) with automatic model selection via Treasury system.

### 12. Quantum Layer Integration

Python-based quantum computation engine (`engine/quantum/`) with Chimera logic and finance bridge for advanced calculations, integrated via TypeScript bridge.

---

## LIMITATIONS & GAPS OBSERVED

### 1. No Cross-Agent Synchronization Primitives

While agents can read from Blackboard, there's no transactional isolation or optimistic locking. Two agents simultaneously writing to same resource could create conflicts.

### 2. Limited Tool Guardrails

The `guardrail` flag in Tool interface is defined but not actively enforced. Dangerous operations (shell, file write) lack execution-level safeguards.

### 3. No Distributed Tracing

While Telemetry records events, there's no end-to-end trace ID correlation across agent boundaries or service calls.

### 4. Python Quantum Layer Loose Integration

The Python `engine/quantum/` appears lightly integrated. The bridge mechanism (`quantumBridge.ts`) exists but integration depth with main swarm is unclear.

### 5. Model Fallback Chain Hardcoded

The 9-tier fallback is hardcoded in BaseAgent. No runtime configuration for model tier order or custom fallback chains.

### 6. Circular Dependency Risk in Multimodal

Vision and Veo don't show complete implementation; they reference an undefined `treasury` module that should manage model selection.

### 7. No Agent State Snapshots

Agents have no built-in checkpoint mechanism. If an agent crashes mid-execution, there's no way to resume from that exact state.

### 8. Limited Error Context in Fallback

When a model fails and triggers fallback, only the newest key is tried with the new model. Historical context might be lost.

### 9. Reactive Only DIS

SwarmDIS only reacts to errors. No proactive health monitoring or predictive healing.

### 10. No Built-in Agent Scheduling

While AutonomousLoop provides 1-hour cycles, there's no cron-like or event-based scheduling system for recurring tasks.

### 11. Blackboard Entry Limits

Fixed max 200 entries (default). No automatic cleanup policy for old entries; they're discarded in FIFO order.

### 12. Treasury System Design Incomplete

Budget constraints, token bucket logic, and model migration are defined but not deeply utilized in BaseAgent/SwarmOrchestrator decision paths.

---

## SCORING SUMMARY

**System Health Score Calculation** (via `LisaOrchestrator.getScore()`):
- Baseline: 38/100
- Per capability enabled: ~5 points (12 capabilities × 5 = 60 additional)
- Maximum: 100/100

**Key Metrics**:
- 8 core agents in parallel swarm
- 9-tier model fallback chain
- 5 concurrent task limit (prevents resource exhaustion)
- 30-second dedup window (DIS)
- 5 fixes/minute circuit breaker (DIS)
- 200 max Blackboard entries
- Hybrid persistence (Dexie + JSON)

---

## CONCLUSION

The Agent Lisa system is a sophisticated, production-grade multi-agent orchestration framework with:
- 8 specialized agents with domain expertise
- Intelligent API key rotation with penalty queue logic
- 9-tier model fallback chain for resilience
- Self-healing error correction (SwarmDIS)
- Hybrid persistence across browser/Node environments
- Semantic knowledge indexing and calibration learning
- Supreme protocol for runtime override
- Autonomous background execution

The system demonstrates strong architectural patterns (Swarm, Blackboard, Factory, Strategy, Pub-Sub) and innovative features like penalty queue rotation and Digital Immune System. While there are gaps in distributed tracing, agent state snapshots, and some incomplete subsystems (Quantum layer, Treasury integration), the core is solid and well-engineered for autonomous multi-agent collaboration in a hybrid Replit/AI Studio environment.
