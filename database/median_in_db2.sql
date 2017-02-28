/* Examples of calculating median in DB2 
 * Code source: https://www.ibm.com/developerworks/community/blogs/SQLTips4DB2LUW/entry/how_to_do_median_in_db253?lang=en
 */

/* Create a simple table (one column) with some data */
create table T(c1, int);
insert into T values 10, 12, 30, 33, 50;

/* Calculate median for the simple data */
select decode((cnt/2)*2, cnt, (c1 + c1_next)/2, c1)
    from ( select c1,
                  lead(c1, 1) over(order by c1) as c1_next,
                  count(c1) over() as cnt,
                  row_number() over(order by c1) as rn
                from T
        )
    where rn = (cnt + 1) / 2;

-- key functions: decode, lead

/* Next, we make the example more complex by calculate median
 * for each partition of the data 
 */

/* Add more data, and another column to indicate group/partition member */
ALTER TABLE T ADD COLUMN c2 INTEGER DEFAULT 1;
INSERT INTO T VALUES (100, 2), (103, 2), (150, 2),
                     ( -5, 3), ( -4, 3), ( -3, 3), (-2, 3), (-1, 3);


/* Calculate median per partition */                     
SELECT c2, DECODE((cnt / 2) * 2, cnt , (c1 + c1next) / 2, c1) 
  FROM (SELECT c1, c2,
               LEAD(c1, 1) OVER(PARTITION BY c2 ORDER BY c1) AS c1next, 
               COUNT(c1) OVER(PARTITION BY c2 ) AS cnt, 
               ROW_NUMBER() OVER(PARTITION BY c2  ORDER BY c1) AS rn 
          FROM T)
    WHERE rn = (cnt + 1) / 2;

-- key function: partition by