package com.ruoyi.project.clinic.ai.service.support;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
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
public class AiInvocationLogService
{
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private final Path logPath = Paths.get("logs", "ai-invocation.log");

    public synchronized void record(String scene, String modelName, boolean success, String failureReason, long durationMs)
    {
        record(scene, modelName, success, failureReason, durationMs, null);
    }

    public synchronized void record(String scene, String modelName, boolean success, String failureReason, long durationMs,
        JSONObject metadata)
    {
        try
        {
            Files.createDirectories(logPath.getParent());
            JSONObject item = new JSONObject();
            item.put("time", FORMATTER.format(LocalDateTime.now()));
            item.put("scene", scene);
            item.put("model", modelName);
            item.put("success", success);
            item.put("failureReason", failureReason);
            item.put("durationMs", durationMs);
            if (metadata != null)
            {
                for (String key : metadata.keySet())
                {
                    if (!item.containsKey(key))
                    {
                        item.put(key, metadata.get(key));
                    }
                }
            }
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
            // Ignore logging failures to avoid breaking the main flow.
        }
    }

    public synchronized List<JSONObject> latest(int limit)
    {
        return latest(limit, null, null, null, null, null);
    }

    public synchronized List<JSONObject> latest(
        int limit,
        String sceneKeyword,
        String modelKeyword,
        Boolean success,
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

            LocalDateTime start = parseDateTime(startTime);
            LocalDateTime end = parseDateTime(endTime);
            String sceneFilter = normalizeKeyword(sceneKeyword);
            String modelFilter = normalizeKeyword(modelKeyword);

            for (int i = lines.size() - 1; i >= 0 && result.size() < effectiveLimit; i--)
            {
                String line = lines.get(i);
                if (line == null || line.trim().isEmpty())
                {
                    continue;
                }
                JSONObject item = JSON.parseObject(line);
                if (!matchKeyword(item.getString("scene"), sceneFilter))
                {
                    continue;
                }
                if (!matchKeyword(item.getString("model"), modelFilter))
                {
                    continue;
                }
                if (!matchSuccess(item, success))
                {
                    continue;
                }
                if (!matchTime(item, start, end))
                {
                    continue;
                }
                result.add(item);
            }
            return result;
        }
        catch (IOException ignored)
        {
            return new ArrayList<JSONObject>();
        }
    }

    private String normalizeKeyword(String keyword)
    {
        if (keyword == null)
        {
            return "";
        }
        return keyword.trim().toLowerCase();
    }

    private boolean matchKeyword(String value, String keyword)
    {
        if (keyword == null || keyword.isEmpty())
        {
            return true;
        }
        return value != null && value.toLowerCase().contains(keyword);
    }

    private boolean matchSuccess(JSONObject item, Boolean successFilter)
    {
        if (successFilter == null)
        {
            return true;
        }
        Boolean success = item.getBoolean("success");
        return success != null && success.booleanValue() == successFilter.booleanValue();
    }

    private boolean matchTime(JSONObject item, LocalDateTime start, LocalDateTime end)
    {
        if (start == null && end == null)
        {
            return true;
        }
        LocalDateTime logTime = parseDateTime(item.getString("time"));
        if (logTime == null)
        {
            return false;
        }
        if (start != null && logTime.isBefore(start))
        {
            return false;
        }
        if (end != null && logTime.isAfter(end))
        {
            return false;
        }
        return true;
    }

    private LocalDateTime parseDateTime(String time)
    {
        if (time == null || time.trim().isEmpty())
        {
            return null;
        }
        try
        {
            return LocalDateTime.parse(time.trim(), FORMATTER);
        }
        catch (Exception ignored)
        {
            return null;
        }
    }
}
