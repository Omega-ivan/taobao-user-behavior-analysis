-- ==========================================
-- 2. 双口径转化漏斗分析
-- ==========================================

-- 2.1 用户级转化漏斗（宽松漏斗）
WITH user_funnel AS (
    SELECT
        user_id,
        MAX(CASE WHEN behavior_type = 'pv'   THEN 1 ELSE 0 END) AS has_pv,
        MAX(CASE WHEN behavior_type = 'fav'  THEN 1 ELSE 0 END) AS has_fav,
        MAX(CASE WHEN behavior_type = 'cart' THEN 1 ELSE 0 END) AS has_cart,
        MAX(CASE WHEN behavior_type = 'buy'  THEN 1 ELSE 0 END) AS has_buy
    FROM user_behavior
    GROUP BY user_id
)
SELECT
    SUM(has_pv)   AS pv_users,
    SUM(has_fav)  AS fav_users,
    SUM(has_cart) AS cart_users,
    SUM(has_buy)  AS buy_users,
    ROUND(SUM(has_cart) * 100.0 / NULLIF(SUM(has_pv), 0), 2) AS cart_rate,
    ROUND(SUM(has_buy)  * 100.0 / NULLIF(SUM(has_cart), 0), 2) AS buy_rate
FROM user_funnel;

-- 2.2 用户-商品级顺序漏斗（严格漏斗）
WITH cart_events AS (
    SELECT user_id, item_id, MIN(datetime) AS cart_time
    FROM user_behavior
    WHERE behavior_type = 'cart'
    GROUP BY user_id, item_id
),
buy_events AS (
    SELECT user_id, item_id, MIN(datetime) AS buy_time
    FROM user_behavior
    WHERE behavior_type = 'buy'
    GROUP BY user_id, item_id
)
SELECT
    COUNT(DISTINCT CONCAT(c.user_id, '-', c.item_id)) AS cart_items,
    COUNT(DISTINCT CASE WHEN b.buy_time > c.cart_time
                        THEN CONCAT(c.user_id, '-', c.item_id) END) AS converted_items,
    ROUND(
        COUNT(DISTINCT CASE WHEN b.buy_time > c.cart_time
                            THEN CONCAT(c.user_id, '-', c.item_id) END) * 100.0
        / NULLIF(COUNT(DISTINCT CONCAT(c.user_id, '-', c.item_id)), 0), 2
    ) AS strict_conversion_rate
FROM cart_events c
LEFT JOIN buy_events b
    ON c.user_id = b.user_id AND c.item_id = b.item_id;