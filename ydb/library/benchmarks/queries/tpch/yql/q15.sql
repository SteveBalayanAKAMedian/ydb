{% include 'header.sql.jinja' %}

-- TPC-H/TPC-R Top Supplier Query (Q15)
-- TPC TPC-H Parameter Substitution (Version 2.17.2 build 0)
-- using 1680793381 as a seed to the RNG

$border = Date("1996-01-01");
$revenue0 = (
    select
        l_suppkey as supplier_no,
        $round(sum(l_extendedprice * ($z1_12 - l_discount)), -8) as total_revenue
    from
        {{lineitem}}
    where
        l_shipdate  >= $border
        and l_shipdate < ($border + Interval("P91D"))
    group by
        l_suppkey
);
$max_revenue = (
select
    max(total_revenue) as max_revenue
from
    $revenue0
);
$join1 = (
select
    s.s_suppkey as s_suppkey,
    s.s_name as s_name,
    s.s_address as s_address,
    s.s_phone as s_phone,
    r.total_revenue as total_revenue
from
    {{supplier}} as s
join
    $revenue0 as r
on
    s.s_suppkey = r.supplier_no
);

select
    j.s_suppkey as s_suppkey,
    j.s_name as s_name,
    j.s_address as s_address,
    j.s_phone as s_phone,
    j.total_revenue as total_revenue
from
    $join1 as j
join
    $max_revenue as m
on
    j.total_revenue = m.max_revenue
order by
    s_suppkey;

