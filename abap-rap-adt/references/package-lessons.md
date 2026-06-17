# Package Lessons

Use this reference when the user mentions an ABAP package or asks to base RAP work on lessons from an existing package.

## Treat The Package As The Teacher

The user-provided package is the live reference. The first task is to inspect it through SAP ADT MCP and build a small map of its objects before designing or editing anything.

Capture:

- Package description and transport layer.
- Object list grouped by type.
- Naming prefixes and suffixes.
- RAP stack shape: table, interface view, projection view, BDEF, class pool, service definition, service binding, metadata extension, DCL.
- Any generator-created naming fragments.
- Behavior patterns: draft/non-draft, managed/unmanaged, numbering, locking, ETags, authorizations, validations, determinations, actions, feature control.
- UI/service pattern: OData version, binding type, published state, entity set names.
- Testing pattern: local ABAP Unit classes, CDS test doubles, behavior test coverage.

## Extraction Template

Use this short table while inspecting:

```text
Object type | Object name | Role in RAP stack | Notes
Table       |             | Persistence        |
DDLS        |             | Interface          |
DDLS        |             | Projection         |
BDEF        |             | Behavior           |
CLAS        |             | Behavior pool      |
DCLS        |             | Access control     |
SRVD        |             | Service definition |
SRVB        |             | Service binding    |
DDLX        |             | Metadata extension |
```

Then summarize the reusable lessons as:

```text
Naming:
Layering:
Behavior:
Service:
Validation/activation:
Tests:
Pitfalls:
```

## Expected Lessons To Check For

Do not assume these are present. Verify them in the package:

- A semantic business key exists alongside technical UUID keys.
- Interface views contain stable data shape and mandatory annotations.
- Projection views stay structural.
- Metadata extensions own UI details when the package uses that style.
- Child entities are modeled as composition only when lifecycle-owned by the root.
- References to SAP or master data use released CDS entities or released APIs.
- Behavior logic is separated into determinations, validations, actions, and feature control.
- Draft BOs use correct draft actions, locks, and ETags.
- Service binding names and generated object names are taken from ADT, not guessed.
- Activation messages are resolved before adding higher-level objects.

## Applying Lessons To New Work

When creating a new object inspired by an existing package:

1. Reuse its naming grammar where possible.
2. Reuse its layering and service exposure style.
3. Keep object names within SAP limits.
4. Prefer generator-generated skeletons only if they can be made consistent with package style.
5. After generation, compare the generated stack to the reference package and patch only real gaps.

## Reporting

When basing a change on a reference package, explicitly state which lessons were observed and reused. Example:

```text
Reused from reference package:
- Naming: <observed convention>
- Behavior: <observed pattern>
- Service exposure: <observed binding/publication pattern>
- Divergence: <intentional difference and reason>
```

If the package cannot be inspected, say so and mark any design as a proposal rather than a package-derived lesson.
