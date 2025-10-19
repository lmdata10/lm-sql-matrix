/*The value may differ, in project analysis the values were taken from the Workbench Explain Analyze
and below are the values from VScode
*/

-> Limit: 1000000 row(s)  (cost=194235 rows=430988) (actual time=24.2..4927 rows=608108 loops=1)
    -> Nested loop inner join  (cost=194235 rows=430988) (actual time=24.2..4888 rows=608108 loops=1)
        -> Nested loop inner join  (cost=43389 rows=430988) (actual time=24.2..3971 rows=608108 loops=1)
            -> Nested loop inner join  (cost=161 rows=118) (actual time=0.128..1.62 rows=334 loops=1)
                -> Filter: (g.fiscal_year = 2021)  (cost=119 rows=118) (actual time=0.102..0.694 rows=334 loops=1)
                    -> Table scan on g  (cost=119 rows=1182) (actual time=0.098..0.573 rows=1182 loops=1)
                -> Single-row index lookup on p using PRIMARY (product_code=g.product_code)  (cost=0.251 rows=1) (actual time=0.00256..0.00259 rows=1 loops=334)
            -> Filter: (get_fiscal_year(s.`date`) = 2021)  (cost=4.18 rows=3646) (actual time=4.62..11.8 rows=1821 loops=334)
                -> Index lookup on s using PRIMARY (product_code=g.product_code)  (cost=4.18 rows=3646) (actual time=0.023..1.28 rows=4082 loops=334)
        -> Single-row index lookup on pid using PRIMARY (customer_code=s.customer_code, fiscal_year=2021)  (cost=0.25 rows=1) (actual time=0.00132..0.00135 rows=1 loops=608108)
