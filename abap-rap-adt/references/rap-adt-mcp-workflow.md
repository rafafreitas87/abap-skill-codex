# RAP ADT MCP Workflow

Use this reference for RAP creation, extension, service exposure, activation, and troubleshooting through SAP ADT MCP.

## MCP Setup Expectations

The SAP ADT MCP server is commonly exposed by the SAP ADT VS Code extension. A healthy setup normally allows Codex to list destinations, inspect or create ABAP objects, call RAP generators, request transports, activate objects, and inspect business services. Tool names vary by client, so discover the available tools instead of hard-coding one namespace.

For long generator runs, warn that the client-side MCP timeout may need to be raised. RAP generator calls can take more than 30 seconds.

## Discovery Checklist

Before changing a RAP object:

1. Confirm target destination/system.
2. Identify package and transport handling.
3. List package objects or search for the object name.
4. Fetch source/metadata for the relevant object set:
   - DDLS/CDS interface views
   - Projection and consumption views
   - BDEF and projection BDEF
   - Behavior pool class and local handlers
   - Metadata extensions
   - DCL/access controls
   - Service definition and service binding
5. Capture current activation or syntax state if exposed.

## Generator-First Decision Tree

Prefer RAP generators when creating a standard new BO stack:

| Need | Preferred path |
| --- | --- |
| New BO with new persistence | `x-ui-service` generator |
| New UI service from existing table | `ui-service` generator |
| Web API only | `webapi-service` generator |
| Existing non-RAP persistence or unusual model | Handcrafted RAP objects |

When using a generator:

- Fetch the generator schema first.
- Preserve any schema `sessionId` or reference token exactly as returned.
- Submit the full JSON spec to the generation tool.
- Use generated object names and URIs from the response. Do not predict names from the input prefix.
- Activate the returned object set as a coherent batch.
- If the client times out, recover by inspecting package objects or business services rather than assuming failure.

## Handcrafted Object Order

When generators do not fit, create or update in this order:

1. Data elements/domains if needed and allowed by local standards.
2. Persistent table and draft table if applicable.
3. Interface CDS view entity.
4. Projection CDS view entity.
5. Metadata extension for UI annotations.
6. Behavior definition for interface/projection.
7. Behavior pool class and local handler/saver classes.
8. DCL/access control.
9. Service definition.
10. Service binding.

Activate after each coherent slice, not after every tiny object if dependencies are incomplete.

## RAP Modeling Defaults

- Use `define view entity`, not legacy `define view`.
- Use managed RAP for new custom persistence.
- Use draft for editable, multi-step Fiori elements apps unless the user explicitly wants a simple non-draft transactional BO.
- Use compositions only for owned child entities.
- Use associations for reference/master data.
- Put UI annotations in metadata extensions or consumption/projection exposure according to local package style.
- Keep projections structural: no joins, case expressions, currency conversions, or hidden business rules.
- Put validations, determinations, actions, and feature control in behavior artifacts.
- Add ABAP Unit coverage for behavior logic when implementing non-trivial validations, determinations, or actions.

## Activation Loop

When activation fails:

1. Read the exact ADT activation messages.
2. Fix dependency order first if objects are missing.
3. Fix syntax and type problems next.
4. Re-activate the smallest complete affected set.
5. Report remaining messages verbatim enough for the user to act.

Do not continue building additional layers while lower layers fail activation.

## Transport Handling

- `$TMP` is acceptable only for throwaway work.
- For real `Z*` packages, ask before selecting or creating a transport.
- Never silently reuse a transport request just because one is available.
- Include transport ID in the final report when writes were made.
