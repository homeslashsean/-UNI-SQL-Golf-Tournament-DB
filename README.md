# Golf Tournament Database

A relational database for managing a golf tournament — players, competitions, referees, caddies, equipment, and results. Built in MySQL.

---

## What's in here

The SQL file sets up the full database from scratch: schema, sample data, and 20 queries covering a range of operations.

**Schema (9 tables)**

| Table | Purpose |
|---|---|
| `Player` | Tournament participants |
| `Ball` | Each player's ball, including brand and signature |
| `Caddy` | Caddies and their favourite tips |
| `Competition` | Events with names and dates |
| `Referee` | Officials and their salaries |
| `Responsible` | Many-to-many link between referees and competitions |
| `PlayingTime` | A player's entry in a competition — start time and result |
| `GolfBag` | Bag assigned to a player, carried by a caddy |
| `Club` | Individual clubs inside a bag (weak entity) |

**Queries (20)**

Covers SELECT, JOIN, subqueries, REGEXP, aggregate functions (AVG, COUNT), GROUP BY / HAVING, ORDER BY, CAST, SUBSTRING_INDEX, UPDATE, and DELETE.

---

## Extra features added after the assignment

A few things were added beyond the original brief to explore what a more complete implementation might look like.

**Performance indexes** — foreign key columns on the referencing side aren't indexed automatically in MySQL, so explicit indexes were added on `Ball.ssn`, `PlayingTime.player_ssn`, `PlayingTime.comp_nam`, `GolfBag.caddy_ssn`, and `Responsible.ref_ssn`.

**Views** — four views were created to make common lookups reusable:
- `vw_leaderboard` — results per competition with a completed/DNF status derived from REGEXP
- `vw_player_equipment` — full player profile: bag, clubs, and caddy in one row
- `vw_referee_workload` — each referee's salary and number of competitions assigned
- `vw_competition_summary` — entries, finishers, DNFs, and average score per event

**Stored procedure** — `GetPlayerHistory(ssn)` returns a player's full competition history including tee times, results, and caddy info.

**Trigger** — `trg_no_duplicate_entry` blocks a player from being registered twice in the same competition. The composite primary key alone doesn't catch this since different start times would otherwise slip through.

---

## Technologies

- MySQL 8
- InnoDB storage engine

---

## Running it

```sql
source golf_tournament.sql
```

Or open it in MySQL Workbench and run the full script. The file drops and recreates the database each time, so it's safe to re-run.
