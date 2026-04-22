package com.ruoyi.framework.config;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 登录限流配置
 * 防止暴力破解登录
 *
 * @author ruoyi
 */
public class RateLimitConfig
{
    /**
     * 最大失败次数
     */
    private static final int DEFAULT_MAX_FAIL_COUNT = 5;

    /**
     * 锁定时间（毫秒），5分钟
     */
    private static final long DEFAULT_LOCK_DURATION = 5 * 60 * 1000;

    /**
     * 当前最大失败次数（可动态调整）
     */
    private volatile int maxFailCount = DEFAULT_MAX_FAIL_COUNT;

    /**
     * 当前锁定时长（毫秒，可动态调整）
     */
    private volatile long lockDuration = DEFAULT_LOCK_DURATION;

    /**
     * 失败次数映射
     */
    private final ConcurrentHashMap<String, AtomicInteger> failCountMap = new ConcurrentHashMap<>();

    /**
     * 锁定结束时间映射
     */
    private final ConcurrentHashMap<String, Long> lockEndTimeMap = new ConcurrentHashMap<>();

    private static final RateLimitConfig INSTANCE = new RateLimitConfig();

    public static RateLimitConfig getInstance()
    {
        return INSTANCE;
    }

    private RateLimitConfig()
    {
    }

    /**
     * 尝试获取登录许可
     *
     * @param username 用户名
     * @return null表示允许登录；返回大于0的值表示锁定结束时间戳
     */
    public Long tryAcquire(String username)
    {
        long now = System.currentTimeMillis();

        // 检查是否已被锁定
        Long lockEnd = lockEndTimeMap.get(username);
        if (lockEnd != null && lockEnd > now)
        {
            return lockEnd;
        }

        // 如果锁已过期，清除记录
        if (lockEnd != null && lockEnd <= now)
        {
            lockEndTimeMap.remove(username);
            failCountMap.remove(username);
        }

        return null;
    }

    /**
     * 记录登录失败
     *
     * @param username 用户名
     */
    public void recordFailure(String username)
    {
        AtomicInteger count = failCountMap.computeIfAbsent(username, k -> new AtomicInteger(0));
        int failCount = count.incrementAndGet();

        if (failCount >= maxFailCount)
        {
            long lockEndTime = System.currentTimeMillis() + lockDuration;
            lockEndTimeMap.put(username, lockEndTime);
            failCountMap.remove(username);
        }
    }

    /**
     * 清除登录失败记录（登录成功后调用）
     *
     * @param username 用户名
     */
    public void clearFailure(String username)
    {
        failCountMap.remove(username);
        lockEndTimeMap.remove(username);
    }

    /**
     * 获取剩余失败次数
     *
     * @param username 用户名
     * @return 剩余允许失败次数
     */
    public int getRemainingAttempts(String username)
    {
        AtomicInteger count = failCountMap.get(username);
        if (count == null)
        {
            return maxFailCount;
        }
        return Math.max(0, maxFailCount - count.get());
    }

    public int getMaxFailCount()
    {
        return maxFailCount;
    }

    public long getLockDuration()
    {
        return lockDuration;
    }

    public synchronized void setPolicy(int maxFailCount, long lockDuration)
    {
        if (maxFailCount < 3)
        {
            this.maxFailCount = 3;
        }
        else if (maxFailCount > 10)
        {
            this.maxFailCount = 10;
        }
        else
        {
            this.maxFailCount = maxFailCount;
        }

        if (lockDuration < 60_000L)
        {
            this.lockDuration = 60_000L;
        }
        else if (lockDuration > 7_200_000L)
        {
            this.lockDuration = 7_200_000L;
        }
        else
        {
            this.lockDuration = lockDuration;
        }
    }
}
