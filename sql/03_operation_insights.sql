-- ==========================================
-- 3. 运营策略与人群洞察
-- ==========================================

-- 3.1 加购未购买人群识别（再营销目标人群）
WITH cart_users AS (
    SELECT DISTINCT user_id FROM user_behavior WHERE behavior_type = 'cart'
),
buy_users AS (
    SELECT DISTINCT user_id FROM user_behavior WHERE behavior_type = 'buy'
)
SELECT COUNT(*) AS cart_no_buy_users
FROM cart_users c
LEFT JOIN buy_users b ON c.user_id = b.user_id
WHERE b.user_id IS NULL;