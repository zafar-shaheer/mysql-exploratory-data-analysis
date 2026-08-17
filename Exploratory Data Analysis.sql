-- Project -  Exploratory Data Analysis

-- To explore the data we have with respect to all of its entries

SELECT *
FROM layoffs_staging_2;

-- Total number of layoffs in the data 
SELECT SUM(total_laid_off) AS Total_laid_off
FROM layoffs_staging_2;

-- Max Laid off 
SELECT MAX(total_laid_off) AS Max_laid_off
FROM layoffs_staging_2;

-- Min Laid off 
SELECT MIN(total_laid_off) AS Min_laid_off
FROM layoffs_staging_2;

-- Date range of the data
SELECT MIN(`date`) AS Starting_date,
		MAX(`date`) AS Date_upto
FROM layoffs_staging_2;

-- Layoff by year
SELECT YEAR(`date`), SUM(total_laid_off) AS Layoff_by_year
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Layoffs by industry
SELECT industry, SUM(total_laid_off) AS Layoff_by_industry
FROM layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC;

-- Layoff by company
SELECT company, SUM(total_laid_off) AS Layoff_by_company
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

-- Layoff by Country
SELECT country, SUM(total_laid_off) AS Layoff_by_country
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC;

-- Layoff by stage
SELECT stage, SUM(total_laid_off) AS Layoff_by_company
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC;

-- Complete layoff with highest funds made
SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Calculating Rolling Total of the laid offs
-- Year/Month wise laid offs
SELECT SUBSTRING(`date`, 1, 7) AS `Month`, SUM(total_laid_off) AS Total_laid_off
FROM layoffs_staging_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1;

-- Now calculatig the rolling sum by making a CTE
WITH rolling_sum AS 
(
SELECT SUBSTRING(`date`, 1, 7) AS `Month`, SUM(total_laid_off) AS Monthly_laid_off
FROM layoffs_staging_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1
)
SELECT `Month`,
		Monthly_laid_off,
        SUM(Monthly_laid_off) OVER(ORDER BY `Month`) AS rolling_sum 
FROM rolling_sum;

