data import_all;
 
*make sure variables to store file name are long enough;
length filename txt_file_name $256;
 
*keep file name from record to record;
retain txt_file_name;
 
*Use wildcard in input;
infile "C:\SASHome\Newfolder\*.txt" eov=eov filename=filename truncover DSD;
 
input  state  $ sex  $ year  $ name $ num;
run;

/*Q3.1 THE MOST GENDER AMBIGUOUS NAME(2013)*/
data ambi_2013;
set import_all;
if year="2013" /*OR year ="1945"*/;
run;

proc sql;
CREATE VIEW ff AS
SELECT name, SUM(num) AS fnum_Total 
FROM ambi_2013
WHERE sex="F"
GROUP BY name /*HAVING SUM(num)> 1000 */
;

CREATE VIEW mm AS
SELECT name, SUM(num) AS mnum_Total 
FROM ambi_2013
WHERE sex="M"
GROUP BY name /*HAVING SUM(num)> 1000 */
;

proc sql outobs=50; /*output only first 10 rows*/
SELECT ff.name,mm.name, ff.fnum_Total , mm.mnum_Total ,ABS((ff.fnum_Total-mm.mnum_Total)/(ff.fnum_Total+mm.mnum_Total)) as diff_per 
FROM ff
FULL JOIN mm
ON ff.name=mm.name
WHERE ABS((ff.fnum_Total-mm.mnum_Total)/(ff.fnum_Total+mm.mnum_Total)) > 0
ORDER BY diff_per;

/*Q3.2 THE MOST GENDER AMBIGUOUS NAME(1945)*/
data ambi_1945;
set import_all;
if year ="1945";
run;

proc sql;
CREATE VIEW f_1945 AS
SELECT name, SUM(num) AS fnum_Total 
FROM ambi_1945
WHERE sex="F"
GROUP by name /*HAVING SUM(num)> 1000 */
;

CREATE VIEW m_1945 AS
SELECT name, SUM(num) AS mnum_Total 
FROM ambi_1945
WHERE sex="M"
GROUP BY name /*HAVING SUM(num)> 1000 */
;


proc sql outobs=10;/*output only first 10 rows*/
SELECT f_1945.name,m_1945.name, f_1945.fnum_Total, m_1945.mnum_Total ,ABS((f_1945.fnum_Total-m_1945.mnum_Total)/(f_1945.fnum_Total+m_1945.mnum_Total)) as diff_per 
FROM f_1945
FULL JOIN m_1945
ON f_1945.name=m_1945.name
WHERE ABS((f_1945.fnum_Total-m_1945.mnum_Total)/(f_1945.fnum_Total+m_1945.mnum_Total)) > 0
ORDER BY diff_per;

/*Q4. LARGEST PERCENTAGE INCREASE AND DECREASE NAME FROM 1980*/

data largest_increase;
set import_all;
if year="1980" OR year ="2014";
run;


proc sql;
CREATE VIEW name_1980 AS
SELECT name, SUM(num) AS Total_1980 
FROM largest_increase
WHERE year="1980"
GROUP BY name;

CREATE VIEW name_2014 AS
SELECT name, SUM(num) AS Total_2014
FROM largest_increase
WHERE year="2014"
GROUP BY name;

/*LARGEST PERCENTAGE INCREASE*/
proc sql outobs=50;/*output only first 50 rows*/
SELECT name_1980.name,name_2014.name, name_1980.Total_1980 , name_2014.Total_2014 ,(name_2014.Total_2014-name_1980.Total_1980)/name_1980.Total_1980 as diff_per 
FROM name_1980
FULL JOIN name_2014
ON name_2014.name=name_1980.name
WHERE (name_2014.Total_2014-name_1980.Total_1980)/name_1980.Total_1980 > 0
ORDER BY diff_per DESC;

/*LARGEST PERCENTAGE DECREASE*/
proc sql outobs=50;/*output only first 50 rows*/
SELECT name_1980.name,name_2014.name, name_1980.Total_1980 , name_2014.Total_2014 ,(name_1980.Total_1980-name_2014.Total_2014)/name_1980.Total_1980 as diff_per 
FROM name_1980
FULL JOIN name_2014
ON name_2014.name=name_1980.name
WHERE (name_1980.Total_1980-name_2014.Total_2014)/name_1980.Total_1980 > 0
ORDER BY diff_per DESC;


/*Q5. SAME INCREASE OR DECREASE NUMBER NAMES*/


proc sql outobs=50;/*output only first 50 rows*/
SELECT name_1980.name,name_2014.name, name_1980.Total_1980 , name_2014.Total_2014 ,ABS(name_2014.Total_2014-name_1980.Total_1980) as diff 
FROM name_1980
FULL JOIN name_2014
ON name_2014.name=name_1980.name
WHERE ABS(name_2014.Total_2014-name_1980.Total_1980) > 0
GROUP BY diff HAVING COUNT(*) > 1
ORDER BY diff DESC;
