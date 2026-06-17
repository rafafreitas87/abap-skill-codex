# Clean Core RAP Rules

Use this reference for ABAP Cloud review, ATC remediation, and RAP code generation.

## Non-Negotiable ABAP Cloud Rules

- Use released SAP APIs only.
- Do not select directly from SAP-owned database tables. Use released CDS view entities or released APIs.
- Do not use classic dynpro/reporting constructs such as `CALL SCREEN`, `SUBMIT`, `CALL TRANSACTION`, `FORM`, or `PERFORM`.
- Do not modify SAP standard objects.
- Do not use unreleased function modules or internal helper classes.
- Do not suppress ATC findings without explicit user approval and a written justification.

## RAP Layering Rules

- Interface view: stable data contract and data shaping.
- Projection view: structural exposure only.
- Consumption/service exposure: consumer-specific annotations and service shape.
- Behavior definition: operations, validations, determinations, actions, locks, ETags, authorization, draft.
- Behavior pool: implementation logic only.
- Metadata extension: UI annotations when the package style supports it.
- Access control: never omit authorization checks for exposed data.

## Required Design Checks

- New custom persistence normally means managed RAP.
- UUID technical keys need a semantic key for human use.
- Draft requires draft table, draft actions, correct lock strategy, and ETag handling.
- Composition means lifecycle ownership; association means reference.
- Validations reject invalid input and should not write data.
- Determinations compute/default data and should not reject.
- Side effects describe UI refresh dependencies.
- Static feature control belongs in BDEF when independent of instance state.
- Dynamic feature control belongs in behavior implementation when based on instance state.
- Behavior implementations with meaningful logic need ABAP Unit tests.

## Review Priority

Order findings by risk:

1. Activation blockers and ABAP Cloud hard errors.
2. Security and authorization gaps.
3. Wrong RAP semantics: composition, draft, locking, behavior separation.
4. Data access and released API problems.
5. Missing tests for behavior logic.
6. Style or maintainability issues.

## ATC Handling

If the MCP exposes ATC:

1. Run ATC against the narrowest useful scope.
2. Group findings by category.
3. Apply mechanical fixes only after user confirmation when the system will be changed.
4. Re-run ATC and report the delta.

If ATC is not exposed, ask the user to paste ATC findings from ADT. Never invent findings.
