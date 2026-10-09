# Superstore ETL & Data Analysis Pipeline

Raw CSV -> Extract -> EDA -> Clean -> Transform -> Analyze -> Load (MySQL) -> SQL reports

## Files
| File | What it is |
|---|---|
| `ETL_Pipeline.ipynb` | Main deliverable: extraction, EDA, cleaning, transformation, analysis, insights, DB load, SQL reports (already executed, outputs included) |
| `raw/superstore_raw.csv` | Raw dataset (300-row sample of Sample Superstore, original messy layout preserved) |
| `prepare_raw_sample.py` | How the raw sample was drawn from the public source (provenance) |
| `superstore_database.sql` | Schema (PKs, FKs, CHECK constraints) + 11 SQL reporting queries |
| `superstore_data_inserts.sql` | The loaded data as INSERT statements (rebuild the DB without Python) |
| `ERD.png` | Entity Relationship Diagram |
| `SQL_Reports.md` | Every SQL query with its result table |
| `data_quality_log.csv` | Every data-quality issue found and how it was handled |
| `figures/` | Charts produced by the notebook |

## Run it
1. Install MySQL 8.0+ and start it.
2. `pip install -r requirements.txt`
3. Set your credentials (edit the config cell in the notebook, or set env vars):
   `DB_USER`, `DB_PASSWORD`, `DB_HOST` (default localhost), `DB_PORT` (default 3306).
   The user needs permission to create a database. The notebook creates `superstore_db`.
4. Run all cells of `ETL_Pipeline.ipynb` from the project folder. It drops/recreates all tables and reloads them (safe to re-run).

## Run only the SQL (no Python)
```
mysql -u <user> -p < superstore_database.sql       # creates schema (+ runs the queries on empty tables)
mysql -u <user> -p < superstore_data_inserts.sql   # loads the data
```
Then re-run the queries in PART 2 of `superstore_database.sql`.
