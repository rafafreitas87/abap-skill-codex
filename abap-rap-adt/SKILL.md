---
name: abap-rap-adt
description: Develop, inspect, review, extend, and troubleshoot ABAP RAP applications through SAP ADT MCP. Use when the user asks Codex to work on ABAP Cloud, RAP business objects, CDS views, behavior definitions, behavior pools, service definitions, service bindings, metadata extensions, ATC issues, or lessons from an existing ABAP package via SAP ADT MCP. Prefer package-first discovery, RAP generators when applicable, clean core rules, activation checks, and package-derived patterns before writing ABAP objects.
---

# ABAP RAP via SAP ADT MCP

Use this skill to work on ABAP RAP applications through a connected SAP ADT MCP server, especially when the request mentions an ABAP package or asks for a RAP implementation that should follow lessons from an existing package.

## First Moves

1. Verify SAP ADT MCP availability before promising system changes. Look for tools whose names mention `abap`, `adt`, `transport`, `activation`, `creation`, `generators`, `repository`, `business_services`, or `object`.
2. If no SAP ADT MCP tools are available, explain that live ABAP inspection or writes require the ADT MCP connection and continue only with pasted source or local artifacts.
3. Identify the target system and scope: BTP ABAP Environment or S/4HANA using ABAP Cloud, package name, object name, transport, and whether the task is read-only or write-capable.
4. For any package used as a reference, inspect existing objects first. Do not recreate patterns from memory; derive names, layering, service shape, behavior style, and transport constraints from the live package.
5. Read only the references needed for the task:
   - RAP design, generation, activation, or service work: `references/rap-adt-mcp-workflow.md`
   - Package pattern extraction: `references/package-lessons.md`
   - Code review, ATC, or clean core checks: `references/clean-core-rap-rules.md`

## Operating Principles

- Use SAP ADT MCP as the source of truth for existing objects, generated object names, activation results, and service bindings.
- Preserve local naming and architecture from the package under work. If the reference package differs from generic RAP examples, follow the package unless it violates ABAP Cloud or activation rules.
- Prefer RAP generators for new standard BO stacks when available. Use handcrafted CDS/BDEF/class objects only when the generator does not fit the requested shape.
- Keep RAP layers separate: persistence table, interface view, projection view, consumption/service exposure, behavior definition, behavior implementation, service definition, service binding, metadata extension, and access control.
- Treat activation and syntax feedback as part of the development loop. After writes, activate the smallest coherent set and report exact failures.
- Ask before creating or selecting a transport request. For `$TMP`, make clear that the work is local/non-transportable.
- Never invent ATC results, repository object contents, service URLs, or generated names. Fetch them through MCP or ask the user for source/output.

## ARC-1 RAP Defaults

Use these defaults when the user asks for new RAP work on an ABAP/S/4HANA system, including on-premise systems, unless they explicitly override them:

- For machine setup/onboarding, use `SETUP_GUIDE_CODEX_CLAUDE_ABAP_RAP.md` from `https://github.com/rafafreitas87/abap-skill-codex`. Do not load the setup guide during normal RAP work unless the user asks for environment setup help.
- Require the system connection details before writes: ADT destination name, host or HTTPS URL, HTTPS port, SAP client, SAP user, package, and transport.
- ARC-1 endpoint format: `https://<host-or-ip>:<https-port>`, with `SAP_CLIENT=<client>` and `SAP_USER=<user>`.
- Use `SAP_INSECURE=true` only for lab/on-premise certificates that are not trusted by the local machine.
- ARC-1/HTTP writes require a SAP password. Before running write, publish, activation, or direct OData test commands, ensure `SAP_PASSWORD` is set for the current shell/session; if it is not set, ask the user for the password.
- Never store or write the SAP password value in a skill, repo file, script, payload, or final answer. Keep it only in the current process environment or transient command context.
- ARC-1 writes require explicit safety env vars: `SAP_ALLOW_WRITES=true`, `SAP_ALLOWED_PACKAGES=<package>`, `SAP_ALLOWED_TRANSPORTS=<transport>`.
- For classes with `FOR BEHAVIOR OF ...`, set ARC-1 payload field `lintBeforeWrite: false` when the generic lint rejects valid behavior pool syntax.
- Prefer official ADT MCP for package/transport checks, service discovery, and verification; use ARC-1 for repository writes that official ADT MCP cannot perform.

For new ZTRF RAP business objects in this landscape:

- Default to managed RAP, draft-enabled, OData V4 UI service, strict mode 2.
- Use the package and transport the user provides; do not assume them across tasks.
- Use semantic business keys with late numbering when requested, not UUID-only business design.
- Create the full stack: persistence table, draft table, interface/root CDS, projection CDS, root/projection BDEF, behavior pool, metadata extension, service definition, service binding.
- Expose list columns and filter fields through DDLX using `@UI.lineItem`, `@UI.identification`, and `@UI.selectionField`.
- Publish the OData V4 service binding after activation, then verify with service metadata or ADT business service tools.

For composition items:

- Let RAP draft/composition control item creation state. Avoid over-custom logic that rewrites item collections while the UI is creating rows.
- If the UX needs a default first item, implement it in the projection BDEF with `use create ( augment )` and a projection behavior class using `MODIFY AUGMENTING ENTITIES`.
- Use a SAP-accepted default unit such as `EA` for simple item examples.
- Be careful with late numbering for child items: never assign the same initial item number to multiple draft children. Number children sequentially within the same save/activation and per parent order.
- Do not trigger total recalculation from a field that the calculation itself updates; avoid loops such as `NetAmount` determination updating `NetAmount` and then retriggering total logic.

For material value help and pricing:

- Use a stable value help entity for selecting existing materials; avoid pointing item value help at an unstable draft editing surface when a read-only/value-help projection is more appropriate.
- Validate that `ProductID` exists before save.
- Load item currency and net amount from material price when product and quantity are provided.
- Calculate header total from item amounts/quantities, and make calculated amount fields readonly in the BDEF.

For custom actions:

- Define the action in the root BDEF, implement it in the behavior pool with `FOR MODIFY ... FOR ACTION ... RESULT result`, expose it in the projection BDEF with `use action`, and add a list-page button with `@UI.lineItem: [{ type: #FOR_ACTION, dataAction: '<ActionName>', ... }]`.
- For a simple block action, model a header field such as `Blocked` and update it to `X` in local mode.

## Standard Workflow

1. Discover context:
   - List destinations or confirm the active ADT destination if the MCP exposes destination tools.
   - Inspect the package/object tree.
   - Fetch relevant object metadata and source.
   - Identify generated or existing RAP service bindings.
2. Plan from evidence:
   - Summarize existing RAP stack and naming.
   - Point out missing information that affects object creation, activation, or behavior semantics.
   - Choose generator, edit, review, or remediation path.
3. Implement in small batches:
   - Validate object creation payloads when the MCP exposes validation.
   - Write one coherent RAP slice at a time.
   - Activate immediately after related objects are created or updated.
4. Verify:
   - Re-fetch changed source or object metadata.
   - Run available checks: activation, syntax, generator response validation, service binding fetch, ATC if exposed.
   - For official ADT MCP versions without ATC/source-read support, ask for pasted results/source instead of fabricating them.
5. Report:
   - List changed objects, activation state, remaining issues, and next system action.
   - Include exact object names returned by ADT MCP.

## Output Style

For implementation work, end with:

```text
Scope: <package/object/request>
Changed objects: <names or none>
Activation: <success/failure/not run>
Verification: <checks performed>
Remaining work: <short list>
```

For read-only review, lead with findings ordered by severity and cite object names, line numbers, or source blocks when available.

## Hard Rules

- Do not write to an ABAP system without a clear target package/object and transport decision.
- Do not assume package object names. Inspect them.
- Do not bypass activation errors. Fix them or report the exact failing object and message.
- Do not use unreleased SAP APIs, direct selects from SAP-owned tables, classic dynpro/reporting constructs, or SAP standard modifications in ABAP Cloud scope.
- Do not put business logic in RAP projection views.
- Do not treat UUID keys as sufficient business design; model a semantic key when creating or extending BOs.
- Do not suppress ATC findings unless the user explicitly provides the check, justification, and approval.
