### One issue or bug per Pull Request

Keep your Pull Requests small. Small PRs are easier to reason about which makes them significantly more likely to get merged.

### Issues before features

If you want to add a feature, consider filing an [Issue](../../issues). An Issue can provide the opportunity to discuss the requirements and implications of a feature with you before you start writing code. This is not a hard requirement, however. Submitting a Pull Request to demonstrate an idea in code is also acceptable, it just carries more risk of change.

### Backwards compatibility

Respect the minimum deployment target. If you are adding code that uses new APIs, make sure to prevent older clients from crashing or misbehaving. Our CI runs against our minimum deployment targets, so you will not get a green build unless your code is backwards compatible.

### Forwards compatibility

Please do not write new code using deprecated APIs.
