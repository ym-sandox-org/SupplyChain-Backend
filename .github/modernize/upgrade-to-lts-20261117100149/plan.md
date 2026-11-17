# Upgrade Plan

## Overview
Upgrade the project's JDK to Java 21. Spring Boot stays pinned at version 2.7.18 as explicitly requested, and no Azure deployment is performed as part of this plan.

## Tasks
See `.metadata/tasks.json` for detailed task breakdown.

1. **001-upgrade-java-21** -- Upgrade JDK/Java language level to 21 only (no Spring Boot, Spring Framework, or Jakarta EE changes).

## Open Questions
- Spring Boot 2.7.18 (Spring Framework 5.x, `javax.*` namespace) officially targets JDK 8-11 per supported compatibility ranges. Running it on Java 21 is unofficial/unsupported by Spring and may surface runtime or library incompatibilities (e.g., reflection access, bytecode version issues in dependencies). Since you explicitly asked to keep Spring Boot at 2.7.18, this plan proceeds with a JDK-only upgrade, but please confirm this is acceptable, or let us know if you'd like to revisit upgrading Spring Boot/Framework for full Java 21 compatibility.
