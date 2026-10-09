-- ==========================================
-- 1. 整体规模与行为分布分析
-- ==========================================

-- 1.1 整体规模统计
SELECT
    COUNT(*) AS total_actions,
    COUNT(DISTINCT user_id) AS uv,
    COUNT(DISTINCT item_id) AS item_count,
    COUNT(DISTINCT category_id) AS category_count
FROM user_behavior;

-- 1.2 四类行为分布
SELECT behavior_type, COUNT(*) AS cnt,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM user_behavior
GROUP BY behavior_type;