package com.ruoyi.project.clinic.audit.service;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.project.system.user.domain.User;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class AuditTrailService
{
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private final Path logPath = Paths.get("logs", "audit-trail.log");

    public synchronized void record(String module, String action, String targetId, String detail)
    {
        try
        {
            Files.createDirectories(logPath.getParent());
            User user = ShiroUtils.getSysUser();
            JSONObject item = new JSONObject();
            item.put("time", FORMATTER.format(LocalDateTime.now()));
            item.put("module", StringUtils.isEmpty(module) ? "unknown" : module);
            item.put("action", StringUtils.isEmpty(action) ? "unknown" : action);
            item.put("targetId", StringUtils.isEmpty(targetId) ? "-" : targetId);
            item.put("detail", StringUtils.isEmpty(detail) ? "-" : detail);
            item.put("operatorId", user != null && user.getUserId() != null ? String.valueOf(user.getUserId()) : "-");
            item.put("operatorName", user != null ? StringUtils.defaultString(user.getUserName(), "-") : "-");
            Files.write(
                logPath,
                Collections.singletonList(item.toJSONString()),
                StandardCharsets.UTF_8,
                StandardOpenOption.CREATE,
                StandardOpenOption.APPEND
            );
        }
        catch (IOException ignored)
        {
            // ignore logging failures
        }
    }

    public synchronized List<JSONObject> latest(
        int limit,
        String module,
        String action,
        String keyword,
        String startTime,
        String endTime
    )
    {
        if (!Files.exists(logPath))
        {
            return new ArrayList<JSONObject>();
        }
        try
        {
            List<String> lines = Files.readAllLines(logPath, StandardCharsets.UTF_8);
            List<JSONObject> result = new ArrayList<JSONObject>();
            int effectiveLimit = Math.max(1, limit);
            String moduleFilter = normalizeText(module);
            String actionFilter = normalizeText(action);
            String keywordFilter = normalizeText(keyword);
            LocalDateTime start = parseDateTime(startTime);
            LocalDateTime end = parseDateTime(endTime);

            for (int i = lines.size() - 1; i >= 0 && result.size() < effectiveLimit; i--)
            {
                String line = lines.get(i);
                if (StringUtils.isEmpty(line))
                {
                    continue;
                }
                JSONObject item = JSON.parseObject(line);
                if (!contains(item.getString("module"), moduleFilter))
                {
                    continue;
                }
                if (!contains(item.getString("action"), actionFilter))
                {
                    continue;
                }
                if (!contains(item.getString("detail"), keywordFilter)
                    && !contains(item.getString("operatorName"), keywordFilter)
                    && !contains(item.getString("targetId"), keywordFilter))
                {
                    continue;
                }
                if (!matchTime(item.getString("time"), start, end))
                {
                    continue;
                }
                result.add(item);
            }
            return result;
        }
        catch (Exception ignored)
        {
            return new ArrayList<JSONObject>();
        }
    }

    private String normalizeText(String value)
    {
        return value == null ? "" : value.trim().toLowerCase();
    }

    private boolean contains(String source, String keyword)
    {
        if (StringUtils.isEmpty(keyword))
        {
            return true;
        }
        return source != null && source.toLowerCase().contains(keyword);
    }

    private LocalDateTime parseDateTime(String value)
    {
        if (StringUtils.isEmpty(value))
        {
            return null;
        }
        try
        {
            return LocalDateTime.parse(value.trim(), FORMATTER);
        }
        catch (Exception ignored)
        {
            return null;
        }
    }

    private boolean matchTime(String value, LocalDateTime start, LocalDateTime end)
    {
        if (start == null && end == null)
        {
            return true;
        }
        LocalDateTime time = parseDateTime(value);
        if (time == null)
        {
            return false;
        }
        if (start != null && time.isBefore(start))
        {
            return false;
        }
        if (end != null && time.isAfter(end))
        {
            return false;
        }
        return true;
    }
}
