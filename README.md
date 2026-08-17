    # Exploratory Data Analysis of Global Layoffs Using MySQL

Repository: `mysql-layoffs-eda`

## Project Overview

This project explores a cleaned dataset of global company layoffs using MySQL. The goal wasn't to answer one specific business question, but to look at the data from a few different angles — overall scale, how layoffs changed over time, which industries and companies were affected most, and how monthly totals accumulate — before any deeper or more targeted analysis is attempted. Exploratory analysis like this is usually the first step in working with a new dataset: it surfaces the shape of the data, what's worth digging into further, and what limitations exist before drawing conclusions.

The dataset used here is the already-cleaned output of a separate data-cleaning project (`layoffs_staging_2`) — duplicates, inconsistent labels, and formatting issues were handled prior to this analysis, not as part of it.

## Dataset

The cleaned dataset (`layoffs_staging_2.csv`) contains **1,995 records** across 9 columns:

| Column | Description |
|---|---|
| `company` | Company name |
| `location` | City/region of the office affected |
| `industry` | Industry category |
| `total_laid_off` | Number of employees laid off |
| `percentage_laid_off` | Layoffs as a proportion of the company's workforce |
| `date` | Date of the layoff announcement |
| `stage` | Company funding stage (e.g. Series B, Post-IPO) |
| `country` | Country |
| `funds_raised_millions` | Total funds raised by the company, in millions |

No information about the dataset's original source is included in the supplied files, so none is claimed here.

## Tools & Technologies

- MySQL
- SQL concepts used: aggregate functions (`SUM()`, `MAX()`, `MIN()`), `GROUP BY`, `ORDER BY`, date functions (`YEAR()`, `SUBSTRING()`), CTEs, and a window function for a rolling/cumulative total

## Questions Explored

**Overall Layoff Scale**
- What is the total number of layoffs recorded?
- What is the largest single layoff figure in the dataset?
- What is the smallest?

**Time Period**
- What date range does the dataset cover?
- How do total layoffs break down by year?
- How do layoffs accumulate month over month?

**Industry**
- Which industries recorded the highest total layoffs?

**Company**
- Which companies recorded the highest total layoffs?

**Country**
- Which countries recorded the highest total layoffs?

**Company Stage**
- How do layoffs vary across company funding stages?

**Complete Company Layoffs**
- Which records show a company laying off 100% of its workforce?
- Among those, how much funding had those companies raised?

**Rolling Layoff Total**
- What does the month-by-month cumulative total of layoffs look like across the full time period?

## Exploratory Analysis

### Overall Layoff Statistics

Three simple aggregate queries establish the scale of the dataset: `SUM(total_laid_off)` for the total across all records, `MAX(total_laid_off)` for the single largest layoff event, and `MIN(total_laid_off)` for the smallest.

### Time-Based Analysis

`MIN(date)` and `MAX(date)` establish the date range covered by the dataset. Layoffs by year are calculated by grouping on `YEAR(date)` and summing `total_laid_off`, ordered by year descending. A separate query breaks this down further by month (covered in the rolling total section below).

### Layoffs by Industry

Total layoffs are grouped by `industry` and summed, sorted in descending order to surface the industries with the highest cumulative layoffs.

### Layoffs by Company

The same aggregation pattern — `GROUP BY company`, `SUM(total_laid_off)`, sorted descending — surfaces which individual companies laid off the most people in total across all their recorded entries.

### Layoffs by Country

Layoffs are grouped by `country` and summed, again sorted descending, to compare totals across countries.

### Layoffs by Company Stage

Grouping by `stage` shows how total layoffs are distributed across company funding stages (e.g. Series A through Series J, Post-IPO, Private Equity, Acquired).

### 100% Layoff Cases

Filtering for `percentage_laid_off = 1` isolates records where the reported layoff figure represents the company's entire workforce. Since `percentage_laid_off` is stored as a decimal proportion, a value of `1` corresponds to 100%. These results are ordered by `funds_raised_millions` descending, which highlights well-funded companies that still shut down entirely — a more notable pattern than a small, thinly-funded company doing the same.

### Monthly Layoffs

`SUBSTRING(date, 1, 7)` extracts the year-month portion of each date (e.g. `2022-11`), which is then used as the grouping key to sum layoffs per month. Rows with a `NULL` date are excluded via the `WHERE` clause, since there's no month to group them into.

### Rolling/Cumulative Layoffs

This is a two-step calculation. First, a CTE (`rolling_sum`) computes the total layoffs for each month, the same way as the monthly breakdown above. Then, a window function runs over that CTE's output:

```sql
SUM(Monthly_laid_off) OVER (ORDER BY `Month`) AS rolling_sum
```

A rolling or cumulative total means each month's value is the sum of that month plus every month before it — so the last row in the result represents the running total of all layoffs recorded up to that point. Structuring it as a CTE first, rather than nesting the window function directly into a raw aggregation, keeps the monthly totals as a clean intermediate result that the window function can then run over in a single, readable step.

## Key SQL Concepts Demonstrated

| SQL Concept | How It Was Used |
|---|---|
| `SUM()` | Total layoffs, overall and by group |
| `MAX()` / `MIN()` | Largest and smallest single layoff figures |
| `GROUP BY` | Aggregating layoffs by year, industry, company, country, and stage |
| `ORDER BY` | Sorting results, e.g. by total layoffs or funds raised |
| `YEAR()` | Extracting the year from `date` for yearly aggregation |
| `SUBSTRING()` | Extracting the year-month portion of `date` for monthly aggregation |
| CTE | Preparing monthly totals as an intermediate step before the rolling calculation |
| Window Function | Calculating the cumulative/rolling layoff total |

## Key Findings

- The dataset shows a combined total of **383,659** layoffs across all records.
- The single largest layoff event recorded is **12,000**, at Google, dated January 2023.
- Layoffs by year show 2022 with the highest total (**160,661**), followed by 2023 (**125,677** — notable given the dataset only covers through March of that year), 2020 (**80,998**), and 2021 considerably lower (**15,823**).
- By industry, **Consumer** (45,182) and **Retail** (43,613) show the highest cumulative layoffs, followed by **Other**, **Transportation**, and **Finance**.
- By company, **Amazon** (18,150) recorded the highest total layoffs, ahead of **Google** (12,000) and **Meta** (11,000).
- By country, the **United States** accounts for the large majority of recorded layoffs (256,559), well ahead of **India** (35,993), the next-highest country.
- By stage, **Post-IPO** companies account for the largest share of total layoffs (204,132) — consistent with these being larger, more established companies with bigger workforces to begin with.
- 116 records show a company laying off 100% of its workforce. Sorted by funding, several of these had raised substantial capital before shutting down entirely — the highest being a company that had raised $2.4 billion, followed by others in the $1–1.8 billion range.
- The month-by-month rolling total shows layoffs building gradually through 2020–2021, then accelerating sharply from mid-2022 onward, with the largest single-month jumps occurring in November 2022 and January 2023.

These are patterns observed in the dataset — the analysis doesn't attempt to explain why layoffs increased or which factors drove them.

## Validation / Data Quality Considerations

This analysis was run entirely on the cleaned `layoffs_staging_2` dataset, not the original raw data. A few characteristics of the cleaned data are worth keeping in mind when interpreting the results above:

- `total_laid_off` has a minimum value of 0 across 378 records. These are not necessarily confirmed zero-layoff events — some represent originally missing values that were standardized to 0 during the cleaning stage, so results involving `MIN()` or aggregations that include these rows should be read with that in mind.
- `percentage_laid_off` is `NULL` for 423 records, meaning the 100%-layoff query only captures companies where that percentage was explicitly reported — it doesn't account for companies that may have shut down completely without a reported percentage.
- `stage` is missing for 5 records and `date` is missing for 1 record; the missing date is excluded from the monthly and rolling-total queries by design, since it has no month to be grouped under.
- `funds_raised_millions` is 0 for 171 records, which may reflect genuinely unfunded companies or missing data — the dataset doesn't distinguish between the two.

None of this was addressed as part of the EDA itself; it's noted here because it affects how confidently some of the findings above should be read.

## Key Learnings

- Aggregate functions like `SUM()`, `MAX()`, and `MIN()` are a fast way to get a sense of a dataset's scale before going any further.
- `GROUP BY` turns a flat table into a comparison across categories — industry, company, country, stage — which is where most of the useful patterns in this dataset actually showed up.
- Date-based aggregation, whether by year or by month, is often where a "single total" number turns into something more interesting — the yearly and monthly breakdowns here told a very different story than the overall sum alone.
- A CTE makes a multi-step calculation easier to reason about — building the monthly totals first, then running the window function over that result, is much clearer than trying to nest both steps into one query.
- A window function like `SUM() OVER (ORDER BY ...)` is a clean way to calculate a running total without needing a self-join or a loop.
- Exploratory analysis is meant to surface patterns and raise questions, not settle them — several of the findings above (like the funding levels behind 100%-layoff companies) are interesting on their own but would need more targeted analysis to draw firmer conclusions from.

## Project Structure

```
mysql-layoffs-eda/
├── Exploratory Data Analysis.sql
├── layoffs_staging_2(1).csv
└── README.md
```

Recommendation: renaming `layoffs_staging_2(1).csv` to something like `layoffs_cleaned.csv` would read more cleanly on GitHub — this isn't the current filename, just a suggested improvement.

## SQL Examples

Aggregating layoffs by year:

```sql
SELECT YEAR(`date`), SUM(total_laid_off) AS Layoff_by_year
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
```

Aggregating layoffs by company:

```sql
SELECT company, SUM(total_laid_off) AS Layoff_by_company
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;
```

CTE plus window function for the rolling total:

```sql
WITH rolling_sum AS (
    SELECT SUBSTRING(`date`, 1, 7) AS `Month`,
           SUM(total_laid_off) AS Monthly_laid_off
    FROM layoffs_staging_2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `Month`
    ORDER BY 1
)
SELECT `Month`,
       Monthly_laid_off,
       SUM(Monthly_laid_off) OVER (ORDER BY `Month`) AS rolling_sum
FROM rolling_sum;
```

## Limitations

- This project describes patterns present in the dataset — it does not investigate or establish *why* layoffs occurred.
- No causal relationships are claimed between industry, funding, company stage, or timing and the layoffs recorded.
- Reported layoff figures reflect what was recorded in the dataset and may not capture every employee affected by a given event.
- Missing values in `percentage_laid_off`, `stage`, and `date` mean some breakdowns (particularly the 100%-layoff and monthly/rolling analyses) are based on a subset of records, not the full dataset.

    
