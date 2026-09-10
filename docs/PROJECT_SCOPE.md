# Project Scope

## Product

This project is a standalone **personal life dashboard**.

It is separate from the user's other applications and should not inherit features, assumptions, or architecture from them unless explicitly requested.

## Long-term dashboard concept

### Desktop

The desktop application is designed for a large monitor and will eventually use a dashboard layout:

```text
┌──────────────────────────────────────────────────────────────┐
│ TODAY SUMMARY                                               │
├─────────────────────────────┬────────────────────────────────┤
│ CLASS SCHEDULE              │ TASKS & REMINDERS              │
├─────────────────────────────┼────────────────────────────────┤
│ SHOPPING                    │ SPENDING                       │
└─────────────────────────────┴────────────────────────────────┘
```

### Mobile

Each main module should have its own page rather than shrinking the desktop dashboard into four small panels.

## Current implementation scope

Only the **Class Schedule module** is in scope.

The other dashboard areas must remain placeholders during this phase.

## Class Schedule module responsibilities

The Class Schedule module serves two purposes.

### Daily reference

Answer quickly:

- What classes do I have today?
- What class is next?
- Where is it?
- When am I free?
- What does my week look like?

### Long-term academic progress

Answer:

- What courses have I completed?
- How many credits have I completed?
- How many credits remain?
- Which graduation categories still need credits?
- What did I take in previous semesters?
- What courses am I planning next semester?
- Will planned courses conflict?
- How would planned courses affect graduation progress?

## Explicit non-goals for Phase 1

Do not implement:

- task management
- shopping functionality
- spending tracking
- habits
- goals
- journaling
- AI features
- Firebase
- cloud synchronization
- paid backend
- Google Calendar integration
- GPA analytics
- attendance tracking
- university portal scraping
- collaboration

The first phase should remain focused and polished.
