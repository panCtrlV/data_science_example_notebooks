/* An example of calculating percentiles in db2. 
 * Code source: https://www.ibm.com/developerworks/community/blogs/SQLTips4DB2LUW/entry/computing_percentile63?lang=en
 * Note the solution in the code source does not calculate the exact percentiles,
 * instead it obtain the max value in each percentage chunk. But it is not difficult to correct.
 */

/* Create a simple table with data */
CREATE TABLE load(server VARCHAR(10), stamp TIMESTAMP, load INTEGER);
INSERT INTO load 
 WITH servers(server) AS (VALUES
  ('Server 1'),
  ('Server 2'),
  ('Server 3'),
  ('Server 4'),
  ('Server 5')),
 stamps(stamp) AS (VALUES
  (CURRENT TIMESTAMP),
  (CURRENT TIMESTAMP + 1 MINUTE),
  (CURRENT TIMESTAMP + 2 MINUTE),
  (CURRENT TIMESTAMP + 3 MINUTE),
  (CURRENT TIMESTAMP + 4 MINUTE),
  (CURRENT TIMESTAMP + 5 MINUTE),
  (CURRENT TIMESTAMP + 6 MINUTE),
  (CURRENT TIMESTAMP + 7 MINUTE),
  (CURRENT TIMESTAMP + 8 MINUTE),
  (CURRENT TIMESTAMP + 9 MINUTE),
  (CURRENT TIMESTAMP + 10 MINUTE),
  (CURRENT TIMESTAMP + 11 MINUTE),
  (CURRENT TIMESTAMP + 12 MINUTE),
  (CURRENT TIMESTAMP + 13 MINUTE),
  (CURRENT TIMESTAMP + 14 MINUTE))
 SELECT server, stamp, NULL FROM servers, stamps;
 
UPDATE load SET load= RAND() * 1000;

/* Calculate 25% percentile of load for each server */
select server, 
       decode( (cnt/4)*4, cnt, (load+load_next)/2, load ) as first_quartile  
    from ( select server, load,
               lead(load, 1) over(partition by server order by load) as lead_next,
               count(load) over(partition by server) as cnt,
               row_number() over (partition by server order by load) as rn 
            from load;
        )
    where rn = cnt / 4 + 1;
